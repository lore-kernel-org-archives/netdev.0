From: Marc Zyngier <marc.zyngier@arm.com>
Subject: Re: [PATCH 2/2] Convert smsc911x to use ACPI as well as DT
Date: Wed, 23 Sep 2015 18:46:24 +0100
Message-ID: <20150923184624.5b255764@arm.com>
References: <1439417187-21411-1-git-send-email-jeremy.linton@arm.com>
	<1439417187-21411-3-git-send-email-jeremy.linton@arm.com>
	<55F059F9.3080200@arm.com>
	<F58048940DF89C44BFA5A966565B5D23EBA361B927@SPOCK.usa.Arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"steve.glendinning@shawell.net" <steve.glendinning@shawell.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"rafael.j.wysocki@intel.com" <rafael.j.wysocki@intel.com>,
	"suravee.suthikulpanit@amd.com" <suravee.suthikulpanit@amd.com>,
	"Catalin Marinas" <Catalin.Marinas@arm.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>
To: Jeremy Linton <Jeremy.Linton@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:35243 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752482AbbIWRq0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2015 13:46:26 -0400
In-Reply-To: <F58048940DF89C44BFA5A966565B5D23EBA361B927@SPOCK.usa.Arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Sep 2015 17:22:49 +0000
Jeremy Linton <Jeremy.Linton@arm.com> wrote:

Hi Jeremy,

> Marc,
> 
> |FWIW, mainline booting with this patch on Juno r1 with ACPI enabled dies a
> |horrible death:
> 
> Sorry about the delay, I didn't see this message.
> 
> <trimmed>
> 
> |How did you get this to work? Firmware release?
> 
> Yes, it's a firmware problem with the ACPI tables. It is likely you
> need _DSD changes for the SMSC. If your trying to run juno with ACPI
> there are a few other ACPI table changes you will need beyond what
> was in the last linaro release. I wanted to just provide a direct
> link to the correct firmware in this response, but it seems the
> required version is sort of up in the air at the moment. Be assured I
> will really push on this next week, and will provide a follow up here.

Good. Please keep me posted on this. I understand this is still a work
in progress, and it would be good to document what is the expected
baseline for this to work correctly.

> Originally, the lack of DSD wasn't a problem, but as this patch
> evolved  the fact that it consolidates a number of configuration code
> paths balancing that got tricky, and ACPI machines with "bad" tables
> were the victims (rather than breaking something I can't control).
> 
> In the meantime, if this is blocking anyone I can provide
> instructions on how to update the required ACPI tables.

Thanks,

	M.
-- 
Jazz is not dead. It just smells funny.
