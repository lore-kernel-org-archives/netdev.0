From: David Miller <davem@davemloft.net>
Subject: Re: Badness at net/ipv4/inet_connection_sock.c:293
Date: Sun, 13 Dec 2009 23:45:30 -0800 (PST)
Message-ID: <20091213.234530.82029083.davem@davemloft.net>
References: <20091212.010340.227842186.davem@davemloft.net>
	<4B2360BF.5000102@gmail.com>
	<4B25D38F.1090702@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lists@nerdbynature.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53753
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751440AbZLNHp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 02:45:29 -0500
In-Reply-To: <4B25D38F.1090702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Dec 2009 06:56:31 +0100

> It seems to me tcp_create_openreq_child() doesnt properly initialize
> newtp->cookie_values to NULL, but this should not produce warnings like that ?

If oldtp->cookie_values is NULL, the child's should be as well
because of sk_clone().
