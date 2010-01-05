From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: RE: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 5 Jan 2010 14:01:19 -0800
Message-ID: <7608421F3572AB4292BB2532AE89D5658B0BAE9450@AVEXMB1.qlogic.org>
References: <7608421F3572AB4292BB2532AE89D5658B0BAE9402@AVEXMB1.qlogic.org>
	<20100105104556.14927d40@nehalam>
	<7608421F3572AB4292BB2532AE89D5658B0BAE9411@AVEXMB1.qlogic.org>
 <20100105.123833.119278401.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	Amit Salecha <amit.salecha@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:57601 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755170Ab0AEWDB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 17:03:01 -0500
In-Reply-To: <20100105.123833.119278401.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You should only do GRO.

Is there problem with stateless packet accumulation by
hardware / firmware when it helps to cut 20% cpu cycles
over GRO and helping some older machines to get line rates
at 10Gbps?

HW LRO is there already in many drivers under different
names (RSC, etc). The difference with netxen_nic and
qlcnic is that it takes care of allowing only local
flows not breaking across bridging or routing topology.

-Dhananjay
