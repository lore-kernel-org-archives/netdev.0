From: David Miller <davem@davemloft.net>
Subject: Re: Badness at net/ipv4/inet_connection_sock.c:293
Date: Mon, 14 Dec 2009 23:18:40 -0800 (PST)
Message-ID: <20091214.231840.106434922.davem@davemloft.net>
References: <20091214.111638.165984790.davem@davemloft.net>
	<4B2690B4.3030604@gmail.com>
	<20091214.143522.102450157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.dykstra1@gmail.com, lists@nerdbynature.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33883
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751628AbZLOHSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 02:18:39 -0500
In-Reply-To: <20091214.143522.102450157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 14 Dec 2009 14:35:22 -0800 (PST)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 14 Dec 2009 20:23:32 +0100
> 
>> If you disable syncookies, I presume you dont have warnings ?
> 
> It happens even with syncookies disabled, hmmm...

FWIW, I'm starting to bisect this.
