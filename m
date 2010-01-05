From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 05 Jan 2010 15:49:28 -0800 (PST)
Message-ID: <20100105.154928.80012641.davem@davemloft.net>
References: <7608421F3572AB4292BB2532AE89D5658B0BAE9411@AVEXMB1.qlogic.org>
	<20100105.123833.119278401.davem@davemloft.net>
	<7608421F3572AB4292BB2532AE89D5658B0BAE9450@AVEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, amit.salecha@qlogic.com,
	netdev@vger.kernel.org
To: dhananjay.phadke@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56152
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754797Ab0AEXtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 18:49:24 -0500
In-Reply-To: <7608421F3572AB4292BB2532AE89D5658B0BAE9450@AVEXMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Date: Tue, 5 Jan 2010 14:01:19 -0800

> HW LRO is there already in many drivers under different
> names (RSC, etc). The difference with netxen_nic and
> qlcnic is that it takes care of allowing only local
> flows not breaking across bridging or routing topology.

We've been gradually removing LRO support from drivers and replacing
it with GRO support.

And meanwhile also encouraging device manufacturers to make their
hardware accumulation support more closely align with being able to
offload GRO natively.
