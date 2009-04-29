From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 0/2] mv643xx_eth fixes for 2.6.30
Date: Wed, 29 Apr 2009 23:56:25 +0200
Message-ID: <20090429215625.GY14729@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:43725 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219AbZD2Vw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 17:52:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two more fixes for mv643xx_eth for 2.6.30:
1. Fix OOM handling, mv643xx_eth will currently just get into an
   infinite netdev_alloc_skb() loop on OOM due to a logic bug.
2. Fix problem where hardware 64bit MIB counters are actually 32bit
   (and reads from the upper and lower halves have the same effect),
   which can cause the software stats counters to spuriously increment
   by some multiple of 2^32 if a packet comes in at the right moment.

Since these should also go into 2.6.29.X, I added "Cc: stable@kernel.org"
on both.

Please apply, thanks!
