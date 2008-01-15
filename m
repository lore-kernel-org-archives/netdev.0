From: "Aggrwal Poonam" <Poonam.Aggrwal@freescale.com>
Subject: RE: [PATCH 0/3] UCC TDM driver for MPC83xx platforms
Date: Tue, 15 Jan 2008 17:35:39 +0530
Message-ID: <FBA61160C48B8D438F3323FEFB4EF2C26E7A6F@zin33exm24.fsl.freescale.net>
References: <FBA61160C48B8D438F3323FEFB4EF2C259F2F6@zin33exm24.fsl.freescale.net> <FBA61160C48B8D438F3323FEFB4EF2C26E7653@zin33exm24.fsl.freescale.net> <20080114120051.3207043b.kim.phillips@freescale.com> <20080114131530.9d33f50a.akpm@linux-foundation.org> <5927F7A4-D42A-40F6-AE9C-EDA34738A752@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Phillips Kim" <Kim.Phillips@freescale.com>,
	<sfr@canb.auug.org.au>, <rubini@vision.unipv.it>,
	<linux-ppcdev@ozlabs.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	"Barkowski Michael" <Michael.Barkowski@freescale.com>,
	"Kalra Ashish" <ashish.kalra@freescale.com>,
	"Cutler Richard" <Rich.Cutler@freescale.com>,
	"Suresh PV" <pala@freescale.com>
To: "Kumar Gala" <galak@kernel.crashing.org>,
	"Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:41912 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbYAOMGC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 07:06:02 -0500
Content-class: urn:content-classes:message
In-Reply-To: <5927F7A4-D42A-40F6-AE9C-EDA34738A752@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Kumar/Morton/Kim

I shall make a small paragraph which describes the TDM driver
architecture and the interfaces it exposes.

As far as 8315 TDM is concerned it is a non QE driver and quite
different from this except for the functionality and external interface
it exposes.

Right now TDM is not a full-fledged bus driver which probably can be
done may be very similar to SPI.

Please give your suggestions on this.

With Regards
Poonam 
 
 

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
