From: Emil Medve <Emilian.Medve@Freescale.com>
Subject: Re: [PATCH 0/7] Freescale DPAA FMan FLIB(s)
Date: Thu, 5 Mar 2015 09:04:54 -0600
Message-ID: <54F87096.2070709@Freescale.com>
References: <1425534351-1065-1-git-send-email-Emilian.Medve@Freescale.com>
 <54F84CF1.80702@mojatatu.com> <54F85ECB.3070200@Freescale.com>
 <54F869CE.1080701@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Igal Liberman <Igal.Liberman@Freescale.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	<linuxppc-dev@lists.ozlabs.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0101.outbound.protection.outlook.com ([207.46.100.101]:41476
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752625AbbCEPE1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 10:04:27 -0500
In-Reply-To: <54F869CE.1080701@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jamal,


On 03/05/2015 08:35 AM, Jamal Hadi Salim wrote:
> Hi Emil,
> 
> On 03/05/15 08:48, Emil Medve wrote:
> 
>> The intent is to upstream the entire suite of the DPAA drivers. All the
>> drivers are still WIP, but B/QMan have been already presented to the
>> upstream community and this is the first attempt to publish (some low
>> level code of) the FMan driver. As we go through our internal checklist
>> and in the same time address community feedback we'll soon get the
>> drivers to be acceptable for the upstream trees
>>
>> The first version of the actual Ethernet driver will follow imminently
>>
>> SDK enablement is a side-effect
> 
> Meaning? Let me ask the question differently:
> Do i need your sdk to use the features exposed

No. All the kernel drivers/code we want to upstream is meant to stand on
its own and be used the "normal" Linux/Unix way

> or can i use something
> like tc to set up the deficit rr or wred or the exposed classifiers
> and associated actions?

The SDK doesn't currently support the enablement of any HW QoS features
via standard Linux user-space tools. The SDK contains some FSL tools for
that. As a time moving target we intend to support lots of the DPAA
features via standard kernel/user-space means: ethtool, iptables,
iproute2, etc.

> Would your sdk (via user space direct programming) benefit because you
> have pushed these pieces into the kernel?

Not specifically because of the kernel drivers. In support for the
user-space DPAA the kernel will have some UIO/VFIO drivers to allow the
user-space to "mmap" these devices (portals, ports, MAC(s), etc.). The
intent is to use the same driver sources for the kernel- and user-space
drivers

>>> How are you planning to
>>> add support for your classifiers, queue schedulers etc?
>>
>> Yes
> 
> Yes as in these will be available via linux kernel or via your sdk?

As in these will be available via familiar kernel-/user-space tools

>>> Is that a patch
>>> on top of this or it is something that sits on user space?
>>
>> Both. Full DPAA/Ethernet enablement will be present in the kernel. We
>> also have support for user-space based approach. I'm unsure where/when
>> we might publish that. Of course the SDK is always a place you can turn
>> to for all the code we have (in whatever state it might be)
> 
> the sdk is open source?

I'm uncertain about *all* the licenses included, but you can look into
it and download the SDK via git.freescale.com and/or
http://www.freescale.com/webapp/sps/site/prod_summary.jsp?code=SDKLINUX


Cheers,
