From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix IP_MULTICAST_IF
Date: Mon, 19 Oct 2009 21:20:18 -0700 (PDT)
Message-ID: <20091019.212018.79580287.davem@davemloft.net>
References: <4ADC96D6.4000909@gmail.com>
	<20091019.205948.193706797.davem@davemloft.net>
	<4ADD3794.8030906@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51781
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751159AbZJTETz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 00:19:55 -0400
In-Reply-To: <4ADD3794.8030906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 20 Oct 2009 06:07:48 +0200

> Final target might be fine, but an element in the chain, before target
> could be deleted while reader scans hash chain.
 ...
> So it should visit a nice memory location ?

It should hit a NULL eventually and deterministically even if an
unlink happens at the same time..... unless the object gets free'd
meanwhile, hmmm...

This code is definitely intentional, I remember when I added it to
the tree, Alexey wrote it :-)
