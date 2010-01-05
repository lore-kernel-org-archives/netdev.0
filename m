From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 5 Jan 2010 10:45:56 -0800
Message-ID: <20100105104556.14927d40@nehalam>
References: <1262697876-26206-1-git-send-email-amit.salecha@qlogic.com>
	<20100105091548.57caf0a4@nehalam>
	<7608421F3572AB4292BB2532AE89D5658B0BAE9402@AVEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Amit Salecha <amit.salecha@qlogic.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43951 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754597Ab0AESqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jan 2010 13:46:15 -0500
In-Reply-To: <7608421F3572AB4292BB2532AE89D5658B0BAE9402@AVEXMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 5 Jan 2010 10:40:35 -0800
Dhananjay Phadke <dhananjay.phadke@qlogic.com> wrote:

> > It looks like this driver is tracking IP addresses? Is it doing
> > some offload? will it work with IPV6?
> 
> Driver listens for "local" IP addresses that helps
> firmware to detect local TCP flows for LRO. We don't
> want firmware to accumulate non-local (forwarded)
> packets. This is inherited from netxen_nic.
> 
> Currently only IPv4 addresses are supported, IPv6 will
> be enabled as soon as firmware advertises support.

You should be doing GRO, what about multiple addresses per interface,
bridging, routing, ...
