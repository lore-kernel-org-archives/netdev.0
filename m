From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 05 Jan 2010 16:33:43 -0800 (PST)
Message-ID: <20100105.163343.14826539.davem@davemloft.net>
References: <7608421F3572AB4292BB2532AE89D5658B0BAE9450@AVEXMB1.qlogic.org>
	<20100105.154928.80012641.davem@davemloft.net>
	<7608421F3572AB4292BB2532AE89D5658B0BAE9471@AVEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, amit.salecha@qlogic.com,
	netdev@vger.kernel.org
To: dhananjay.phadke@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47492
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754349Ab0AFAdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 19:33:40 -0500
In-Reply-To: <7608421F3572AB4292BB2532AE89D5658B0BAE9471@AVEXMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Date: Tue, 5 Jan 2010 15:55:10 -0800

> The LRO you are talking about was still kernel based
> LRO. Even GRO doesn't save PCIe transactions as much
> HW LRO does. That is the key. The difference between
> HW LRO and GRO is significant to keep former alive
> for a while.

But HW LRO is not bridge/forwarding/etc. agnostic because it loses
information.

As soon as I turn on forwarding to make a NAT box or whatever, all of
the hw LRO gets turned off and we're back to square one for local
connections on the machine.
