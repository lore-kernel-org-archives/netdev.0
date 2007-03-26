From: David Miller <davem@davemloft.net>
Subject: Re: [irda-users] [2.6.20-rt8] "Neighbour table overflow."
Date: Sun, 25 Mar 2007 18:36:22 -0700 (PDT)
Message-ID: <20070325.183622.26278284.davem@davemloft.net>
References: <Pine.LNX.4.63.0703231309170.534@pcgl.dsa-ac.de>
	<20070324.221034.45741983.davem@davemloft.net>
	<20070325235058.GA3715@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gl@dsa-ac.de, irda-users@lists.sourceforge.net, paulus@samba.org,
	netdev@vger.kernel.org
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53396
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933339AbXCZBgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2007 21:36:23 -0400
In-Reply-To: <20070325235058.GA3715@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel@sortiz.org>
Date: Mon, 26 Mar 2007 02:50:59 +0300

> I still think Guennadi's fix is correct even if you return 0 from the TX
> function only when you're running out of space. If we unregister the ppp
> interface before we get a chance to call ppp_output_wake(), then we'll leak
> an xmit_pending skb.

I agree, especially after thinking about this some more.

It's just really weird that we've never hit this before,
since this logic has been there forever, that's all :-)
