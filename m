From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: Fix delay handling
Date: Thu, 01 Oct 2009 09:29:20 -0700 (PDT)
Message-ID: <20091001.092920.246088613.davem@davemloft.net>
References: <20090930172532.2c2d1d42@s6510>
	<4AC47AB6.9000501@gmail.com>
	<4AC47EB9.6070809@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, jdb@comx.dk, robert@herjulf.net,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33069
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751587AbZJAQ3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 12:29:02 -0400
In-Reply-To: <4AC47EB9.6070809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 01 Oct 2009 12:04:41 +0200

> But it appears net/core/pktgen.c is different on net-next-2.6
> 
> Stephen, David, I am a bit lost here, something went wrong in a merge process ?
> 

net-next-2.6 is just a stale old tree, there is no new networking
work in there and it is simply Linus's tree as of a few weeks
ago.

It's only there so Stephen Rothwell has something to do a 'nop'
pull from into his linux-next tree.

I'll apply your fix, thanks!
