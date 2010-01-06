From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: RE: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 5 Jan 2010 17:56:00 -0800
Message-ID: <7608421F3572AB4292BB2532AE89D5658B0BAE949E@AVEXMB1.qlogic.org>
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
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:10772 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755292Ab0AFB5n convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 20:57:43 -0500
In-Reply-To: <20100105.163343.14826539.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> But HW LRO is not bridge/forwarding/etc. agnostic because it loses
> information.
> 
> As soon as I turn on forwarding to make a NAT box or whatever, all of
> the hw LRO gets turned off and we're back to square one for local
> connections on the machine.

I won't defend other vendors' implementation. Even if LRO was
not turned off for bridge/forwarding, we still wouldn't accumulate
those remote flows because the dest IP address is not configured in
firmware in our case. This is the reason why we have a inet
notification listener (to tell firmware about local addresses).

-Dhananjay

