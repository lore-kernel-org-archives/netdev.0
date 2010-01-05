From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: RE: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 5 Jan 2010 10:40:35 -0800
Message-ID: <7608421F3572AB4292BB2532AE89D5658B0BAE9402@AVEXMB1.qlogic.org>
References: <1262697876-26206-1-git-send-email-amit.salecha@qlogic.com>
 <20100105091548.57caf0a4@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:45886 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753660Ab0AESmR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 13:42:17 -0500
In-Reply-To: <20100105091548.57caf0a4@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It looks like this driver is tracking IP addresses? Is it doing
> some offload? will it work with IPV6?

Driver listens for "local" IP addresses that helps
firmware to detect local TCP flows for LRO. We don't
want firmware to accumulate non-local (forwarded)
packets. This is inherited from netxen_nic.

Currently only IPv4 addresses are supported, IPv6 will
be enabled as soon as firmware advertises support.

-Dhananjay
