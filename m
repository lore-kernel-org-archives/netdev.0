From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: RE: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 5 Jan 2010 15:55:10 -0800
Message-ID: <7608421F3572AB4292BB2532AE89D5658B0BAE9471@AVEXMB1.qlogic.org>
References: <7608421F3572AB4292BB2532AE89D5658B0BAE9411@AVEXMB1.qlogic.org>
	<20100105.123833.119278401.davem@davemloft.net>
	<7608421F3572AB4292BB2532AE89D5658B0BAE9450@AVEXMB1.qlogic.org>
 <20100105.154928.80012641.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	Amit Salecha <amit.salecha@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:4655 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753593Ab0AEX4x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 18:56:53 -0500
In-Reply-To: <20100105.154928.80012641.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We've been gradually removing LRO support from drivers and replacing
> it with GRO support.

> And meanwhile also encouraging device manufacturers to make their
> hardware accumulation support more closely align with being able to
> offload GRO natively.

The LRO you are talking about was still kernel based
LRO. Even GRO doesn't save PCIe transactions as much
HW LRO does. That is the key. The difference between
HW LRO and GRO is significant to keep former alive
for a while.

-Dhananjay
