From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v1 5/6] tg3: implementation of a non-NAPI mode
Date: Fri, 16 Dec 2011 19:30:26 +0000
Message-ID: <1324063826.2798.8.camel@bwh-desktop>
References: <cover.1324059527.git.decot@googlers.com>
	 <6d55ce25f5f237a4538f6a2fcd2609b877669297.1324059527.git.decot@googlers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Javier Martinez Canillas <martinez.javier@gmail.com>,
	Robin Getz <rgetz@blackfin.uclinux.org>,
	Matt Mackall <mpm@selenic.com>,
	Tom Herbert <therbert@google.com>
To: David Decotigny <decot@googlers.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:48807 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752264Ab1LPTae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 14:30:34 -0500
In-Reply-To: <6d55ce25f5f237a4538f6a2fcd2609b877669297.1324059527.git.decot@googlers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-12-16 at 10:19 -0800, David Decotigny wrote:
> From: Tom Herbert <therbert@google.com>
> 
> The tg3 NIC has a hard limit of 511 descriptors for the receive ring.
> Under heavy load of small packets, this device receive queue may not
> be serviced fast enough to prevent packets drops.  This could be due
> to a variety of reasons such as lengthy processing delays of packets
> in the stack, softirqs being disabled too long, etc.
[...]

I think those are bugs to be fixed, not worked around.

Various drivers had NAPI as a compile-time option for a while, and
pretty much all of those have now been made to use NAPI unconditionally
(I think tulip is the only one left).  Adding such an option back is
unlikely to be accepted now.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
