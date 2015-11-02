From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [PATCH 2/2] Convert smsc911x to use ACPI as well as DT
Date: Mon, 2 Nov 2015 09:48:06 -0600
Message-ID: <563785B6.50800@arm.com>
References: <1439417187-21411-1-git-send-email-jeremy.linton@arm.com>
 <1439417187-21411-3-git-send-email-jeremy.linton@arm.com>
 <55F059F9.3080200@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Content-Transfer-Encoding: 8BIT
Cc: "steve.glendinning@shawell.net" <steve.glendinning@shawell.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"rafael.j.wysocki@intel.com" <rafael.j.wysocki@intel.com>,
	"suravee.suthikulpanit@amd.com" <suravee.suthikulpanit@amd.com>,
	Catalin Marinas <Catalin.Marinas@arm.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>
To: Marc Zyngier <marc.zyngier@arm.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu-smtp-delivery-143.mimecast.com ([207.82.80.143]:46420 "EHLO
	eu-smtp-delivery-143.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753411AbbKBPsN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2015 10:48:13 -0500
In-Reply-To: <55F059F9.3080200@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/2015 11:10 AM, Marc Zyngier wrote:
> Jeremy,
>
> I can see two issues here: we have a screaming interrupt, and
> we seem to corrupt some workqueue.
>
> How did you get this to work? Firmware release?

Marc,

I'm responding because its been a month or so since my last response, 
and I haven't forgotten about this issue.

First, any custom tianocore build (*) should work. The required changes 
have been in the last few linaro snapshots as well 
(http://snapshots.linaro.org/components/kernel/linaro-edk2/, currently 
at 40) but I personally haven't had a lot of luck with the prebuilt 
images due to problems unrelated to this change. Others may have more luck.

* For those that don't know, tianno core is at:

https://github.com/tianocore/edk2.git
Use the master branch

After setting the environment variables/dependencies appropriately:

make -f ArmPlatformPkg/ArmJunoPkg/Makefile all

Will create a functional ACPI firmware image for all recent kernels, 
including ACPI/PCIe ones.

Thanks for everyone's patience on this,

	
