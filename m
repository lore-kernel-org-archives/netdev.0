From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: RE: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 5 Jan 2010 18:19:29 -0800
Message-ID: <7608421F3572AB4292BB2532AE89D5658B0BAE94A3@AVEXMB1.qlogic.org>
References: <7608421F3572AB4292BB2532AE89D5658B0BAE9450@AVEXMB1.qlogic.org>
	<20100105.154928.80012641.davem@davemloft.net>
	<7608421F3572AB4292BB2532AE89D5658B0BAE9471@AVEXMB1.qlogic.org>
 <20100105.163343.14826539.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	Amit Salecha <amit.salecha@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dhananjay Phadke <dhananjay.phadke@qlogic.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:11937 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754818Ab0AFCVL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 21:21:11 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I won't defend other vendors' implementation. Even if LRO was
> not turned off for bridge/forwarding, we still wouldn't accumulate
> those remote flows because the dest IP address is not configured in
> firmware in our case. This is the reason why we have a inet
> notification listener (to tell firmware about local addresses).

May be I should clarify further. Driver does check if the net device
is owned by a qlogic (or netxen) pci device then only will care
about telling firmware about the IP address.

On NAT box, the IP address belonging to tap/tun device won't land into
firmware preventing any packet accumulation in HW.

-Dhananjay

