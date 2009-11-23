From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: Fix device name compares
Date: Mon, 23 Nov 2009 10:39:05 -0800 (PST)
Message-ID: <20091123.103905.176285358.davem@davemloft.net>
References: <4B0A75A5.8000106@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robert.olsson@its.uu.se
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35531
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755134AbZKWSis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 13:38:48 -0500
In-Reply-To: <4B0A75A5.8000106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 23 Nov 2009 12:44:37 +0100

> Commit e6fce5b916cd7f7f7 (pktgen: multiqueue etc.) tried to relax
> the pktgen restriction of one device per kernel thread, adding a '@'
> tag to device names.
> 
> Problem is we dont perform check on full pktgen device name.
 ...
> Solution to this problem is to use a odevname field (includes @ tag and suffix),
> instead of using netdevice name.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
