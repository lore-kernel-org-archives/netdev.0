From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [RFC v1] virtio: add virtio-over-PCI driver
Date: Thu, 19 Feb 2009 09:03:14 -0800
Message-ID: <20090219170313.GC12795@ovro.caltech.edu>
References: <20090217222425.GA18801@ovro.caltech.edu> <D999D051-E5A2-4915-893D-E3384EC312A4@kernel.crashing.org> <7DF0AF56456B8F4081E3C44CCCE311DE1519A3@zch01exm23.fsl.freescale.net> <C04B22C6-BCE8-4D99-A160-22F8846C8209@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zang Roy-R61911 <tie-fei.zang@freescale.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:44124 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752997AbZBSRDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 12:03:16 -0500
Content-Disposition: inline
In-Reply-To: <C04B22C6-BCE8-4D99-A160-22F8846C8209@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 19, 2009 at 10:51:43AM -0600, Kumar Gala wrote:
>
> On Feb 19, 2009, at 12:13 AM, Zang Roy-R61911 wrote:
>
>>
>>
>>> -----Original Message-----
>>> From:
>>> linuxppc-dev-bounces+tie-fei.zang=freescale.com@ozlabs.org
>>> [mailto:linuxppc-dev-bounces+tie-fei.zang=freescale.com@ozlabs
>>> .org] On Behalf Of Kumar Gala
>>> Sent: Thursday, February 19, 2009 0:47 AM
>>> To: Ira Snyder
>>> Cc: Arnd Bergmann; Jan-Bernd Themann; netdev@vger.kernel.org;
>>> Rusty Russell; linux-kernel@vger.kernel.org; linuxppc-dev@ozlabs.org
>>> Subject: Re: [RFC v1] virtio: add virtio-over-PCI driver
>>>
>>>
>>> On Feb 17, 2009, at 4:24 PM, Ira Snyder wrote:
>>>
>>>>
>>>> Documentation/virtio-over-PCI.txt     |   61 ++
>>>> arch/powerpc/boot/dts/mpc834x_mds.dts |    7 +
>>>
>>> we'll have to review the .dts and expect a documentation update for
>>> the node.  But that's pretty minor at this point.
>>>
>>>> drivers/virtio/Kconfig                |   22 +
>>>> drivers/virtio/Makefile               |    2 +
>>>> drivers/virtio/vop.h                  |  119 ++
>>>> drivers/virtio/vop_fsl.c              | 1911
>>> ++++++++++++++++++++++++
>>>> +++++++++
>>>
>>> make this vop_fsl_mpc83xx.c or something along those lines.
>> why?
>
> so we can deal with 85xx as well.  We just need to isolate the 83xx  
> specific bits (message usage)
>

In fact, most of the driver has nothing to do with hardware, and
everything to do with managing memory.

Most of the driver could be shared between implementations. The only
things that would be hardware specific are setting up the descriptor
memory, and raising/handling interrupts.

I just wanted to get something working and out here to discuss. I
figured that more hardware support, features, etc. could come later.
Just like everything else in the kernel, I'm sure this will have to
evolve over time as well.

Thanks,
Ira
