From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 05 Jan 2010 23:43:37 +0000
Message-ID: <1262735017.26813.52.camel@localhost>
References: <1262697876-26206-1-git-send-email-amit.salecha@qlogic.com>
	 <20100105091548.57caf0a4@nehalam>
	 <7608421F3572AB4292BB2532AE89D5658B0BAE9402@AVEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Amit Salecha <amit.salecha@qlogic.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:13488 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642Ab0AEXnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 18:43:45 -0500
In-Reply-To: <7608421F3572AB4292BB2532AE89D5658B0BAE9402@AVEXMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-01-05 at 10:40 -0800, Dhananjay Phadke wrote:
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

LRO will automatically be disabled on interfaces that have forwarding or
bridging enabled.  You should not need to check for this yourself.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

