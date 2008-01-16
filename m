From: "Kalra Ashish" <ashish.kalra@freescale.com>
Subject: RE: [PATCH 0/3] UCC TDM driver for MPC83xx platforms
Date: Wed, 16 Jan 2008 17:17:38 +0530
Message-ID: <2A6F278C5B66C4459AF4013E77A40CD301149086@zin33exm20.fsl.freescale.net>
References: <5927F7A4-D42A-40F6-AE9C-EDA34738A752@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Phillips Kim" <Kim.Phillips@freescale.com>,
	"Aggrwal Poonam" <Poonam.Aggrwal@freescale.com>,
	<sfr@canb.auug.org.au>, <rubini@vision.unipv.it>,
	<linux-ppcdev@ozlabs.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	"Barkowski Michael" <Michael.Barkowski@freescale.com>,
	"Cutler Richard" <Rich.Cutler@freescale.com>,
	"Kalra Ashish" <ashish.kalra@freescale.com>,
	"Suresh PV" <pala@freescale.com>
To: "Kumar Gala" <galak@kernel.crashing.org>,
	"Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:34799 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751453AbYAPLsA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 06:48:00 -0500
Content-class: urn:content-classes:message
In-Reply-To: <5927F7A4-D42A-40F6-AE9C-EDA34738A752@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello All,
 
I am sure that the TDM bus driver model/framework will make us put a lot
more programming effort without
any assurance of the code being accepted by the Linux community,
especially as there are many
Telephony/VoIP stack implementations in Linux such as the Sangoma
WANPIPE Kernel suite which
have their own Zaptel TDM (channelized zero-copy) interface layer. There
are other High Speed serial (HSS)
API interfaces, again supporting channelized and/or prioritized API
interfaces. All these implementations 
are proprietary and have their own tightly coupled upper layers and
hardware abstraction layers. It is
difficult to predict that these stacks will move towards a generic TDM
bus driver interface. Therefore, i think
we can have our own tightly coupled interface with our VoIP framework
and let us the keep the driver as it is,
i.e., as a misc driver.

Ashish

-----Original Message-----
From: Kumar Gala [mailto:galak@kernel.crashing.org] 
Sent: Tuesday, January 15, 2008 9:01 AM
To: Andrew Morton
Cc: Phillips Kim; Aggrwal Poonam; sfr@canb.auug.org.au;
rubini@vision.unipv.it; linux-ppcdev@ozlabs.kernel.org;
netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Barkowski Michael;
Kalra Ashish; Cutler Richard
Subject: Re: [PATCH 0/3] UCC TDM driver for MPC83xx platforms


On Jan 14, 2008, at 3:15 PM, Andrew Morton wrote:

> On Mon, 14 Jan 2008 12:00:51 -0600
> Kim Phillips <kim.phillips@freescale.com> wrote:
>
>> On Thu, 10 Jan 2008 21:41:20 -0700
>> "Aggrwal Poonam" <Poonam.Aggrwal@freescale.com> wrote:
>>
>>> Hello  All
>>>
>>> I am waiting for more feedback on the patches.
>>>
>>> If there are no objections please consider them for 2.6.25.
>>>
>> if this isn't going to go through Alessandro Rubini/misc drivers, can

>> it go through the akpm/mm tree?
>>
>
> That would work.  But it might be more appropriate to go Kumar-
> >paulus->Linus.

I'm ok w/taking the arch/powerpc bits, but I"m a bit concerned about  
the driver itself.  I'm wondering if we need a TDM framework in the  
kernel.

I guess if Poonam could possibly describe how this driver is actually  
used that would be helpful.  I see we have 8315 with a discrete TDM  
block and I'm guessing 82xx/85xx based CPM parts of some form of TDM  
as well.

- k
