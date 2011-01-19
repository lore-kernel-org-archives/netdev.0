From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Question on RX packet classification in ethtool userspace
Date: Wed, 19 Jan 2011 23:19:29 +0000
Message-ID: <1295479169.2906.53.camel@localhost>
References: <80769D7B14936844A23C0C43D9FBCF0F25C04CB6B2@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"santwona.behera@sun.com" <santwona.behera@sun.com>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:25279 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754435Ab1ASXTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 18:19:32 -0500
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F25C04CB6B2@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-01-19 at 14:52 -0800, Duyck, Alexander H wrote:
> So I was looking into the option of replacing the ETHTOOL_GRXNTUPLE
> call with something like ETHTOOL_GRXCLSRLALL and it seems like I
> wasn't having much luck finding the userspace implementation in the
> ethtool.

I wasn't aware until now that there was a public implementation!

> I eventually found a patch in patchwork at
> http://patchwork.ozlabs.org/patch/23223/ which is supposed to add
> support but the current ethtool git tree doesn't appear to contain
> this code.  I was wondering if I am missing something and it is on a
> branch somewhere, or is this something that was not applied to the
> userspace for some specific reason?

Thanks for digging this up.  It's not in any branch that I know of.  I'm
about to go on vacation, but I'll look at it when I get back.  I would
appreciate it if someone would refresh the patch against current ethtool
(preferably reusing some of the functions added for the RX n-tuple
operations).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

