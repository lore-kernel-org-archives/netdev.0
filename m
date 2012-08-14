From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH 2/2] powerpc/85xx: add Fman MDIO muxing support to the
 P4080DS
Date: Tue, 14 Aug 2012 16:58:33 -0500
Message-ID: <502ACA09.6070906@freescale.com>
References: <1344637896-14267-1-git-send-email-timur@freescale.com> <1344637896-14267-2-git-send-email-timur@freescale.com> <5F0028FE-C555-47DE-B69A-888E7322A6E1@kernel.crashing.org> <502AC7C3.9030902@freescale.com> <502AC8D3.4010602@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <galak@kernel.crashing.org>,
	Andy Fleming <afleming@freescale.com>, <ddaney.cavm@gmail.com>,
	<linuxppc-dev@ozlabs.org>, <netdev@vger.kernel.org>
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:36336
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750756Ab2HNV6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 17:58:38 -0400
In-Reply-To: <502AC8D3.4010602@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Wood wrote:

> I think that was internally, and not on this specific comment wording.
> I don't think that code comment adequately explains things.

I don't really have any more insight to add.

>> otherwise, the mdio-mux code would not prepare the mdio mus in time, and
>> there would be initialization failures.  Now maybe this goes away with
>> -EPROBE_DEFER, or maybe it doesn't.  But until we push the DPAA drivers
>> upstream, we won't know.
> 
> Do you know if it's theoretically supposed to be fixed and just can't
> test it, or are you unsure of whether it's even supposed to work?

I'm not sure of anything.  For one thing, we don't implement EPROBE_DEFER
in the DPAA drivers, so we'd probably have to fix that before anything.
And then, I'm just guessing that's the solution.

> I don't think we should be relying on the order of this list to
> determine probe order.  For one thing, it won't work if the drivers
> register after you create the platform devices (e.g. they're modules).

I agree we should not be relying on the order, but I don't know what to
do.  EPROBE_DEFER was designed to handle this situation, so my
recommendation is to worry about it later.  I can beef up the comment to
talk about that, if you want.

-- 
Timur Tabi
Linux kernel developer at Freescale
