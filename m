From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Improved network performance by balancing Rx against
 other work
Date: Sun, 21 Mar 2010 21:24:49 -0700 (PDT)
Message-ID: <20100321.212449.85412927.davem@davemloft.net>
References: <877hp5rohj.wl%peterc@chubb.wattle.id.au>
	<20100321.211124.216749316.davem@davemloft.net>
	<8739ztrnrp.wl%peterc@chubb.wattle.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peter.chubb@nicta.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37730
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751634Ab0CVEY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 00:24:26 -0400
In-Reply-To: <8739ztrnrp.wl%peterc@chubb.wattle.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Chubb <peter.chubb@nicta.com.au>
Date: Mon, 22 Mar 2010 15:19:54 +1100

> David> It's one of the best drivers in the locking area.
> 
> It looked good from that aspect, but used too many features of NAPI
> for me to modify quickly, and still have a simple and
> easy-to-understand patch.

What's so complicated about it?  All of the NAPI logic is
locks into a wrapper function that encapsulates all of
the top-level budget and interrupt masking logic.

> Anyway, I'm intending to try to reproduce the results with a different
> driver, as I said.

Well, you do so at your own peril.  tg3 is the best, whereas
r8169 is really awful and people report NAPI wedges with it
all the time.
