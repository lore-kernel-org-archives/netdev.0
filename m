From: Jeremy Linton <Jeremy.Linton@arm.com>
Subject: RE: [PATCH 2/2] Convert smsc911x to use ACPI as well as DT
Date: Wed, 23 Sep 2015 10:22:49 -0700
Message-ID: <F58048940DF89C44BFA5A966565B5D23EBA361B927@SPOCK.usa.Arm.com>
References: <1439417187-21411-1-git-send-email-jeremy.linton@arm.com>
 <1439417187-21411-3-git-send-email-jeremy.linton@arm.com>
 <55F059F9.3080200@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: 8BIT
Cc: "steve.glendinning@shawell.net" <steve.glendinning@shawell.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"rafael.j.wysocki@intel.com" <rafael.j.wysocki@intel.com>,
	"suravee.suthikulpanit@amd.com" <suravee.suthikulpanit@amd.com>,
	Catalin Marinas <Catalin.Marinas@arm.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>
To: Marc Zyngier <Marc.Zyngier@arm.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu-smtp-delivery-143.mimecast.com ([146.101.78.143]:53537 "EHLO
	eu-smtp-delivery-143.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755750AbbIWRXI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2015 13:23:08 -0400
In-Reply-To: <55F059F9.3080200@arm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marc,

|FWIW, mainline booting with this patch on Juno r1 with ACPI enabled dies a
|horrible death:

Sorry about the delay, I didn't see this message.

<trimmed>

|How did you get this to work? Firmware release?

Yes, it's a firmware problem with the ACPI tables. It is likely you need _DSD changes for the SMSC. If your trying to run juno with ACPI there are a few other ACPI table changes you will need beyond what was in the last linaro release. I wanted to just provide a direct link to the correct firmware in this response, but it seems the required version is sort of up in the air at the moment. Be assured I will really push on this next week, and will provide a follow up here.

Originally, the lack of DSD wasn't a problem, but as this patch evolved  the fact that it consolidates a number of configuration code paths balancing that got tricky, and ACPI machines with "bad" tables were the victims (rather than breaking something I can't control).

In the meantime, if this is blocking anyone I can provide instructions on how to update the required ACPI tables.

Thanks,



-- IMPORTANT NOTICE: The contents of this email and any attachments are confidential and may also be privileged. If you are not the intended recipient, please notify the sender immediately and do not disclose the contents to any other person, use it for any purpose, or store or copy the information in any medium.  Thank you.

ARM Limited, Registered office 110 Fulbourn Road, Cambridge CB1 9NJ, Registered in England & Wales, Company No:  2557590
ARM Holdings plc, Registered office 110 Fulbourn Road, Cambridge CB1 9NJ, Registered in England & Wales, Company No:  2548782
