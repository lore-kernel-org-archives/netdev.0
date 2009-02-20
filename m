From: "Zang Roy-R61911" <tie-fei.zang@freescale.com>
Subject: RE: [RFC v1] virtio: add virtio-over-PCI driver
Date: Fri, 20 Feb 2009 11:44:53 +0800
Message-ID: <7DF0AF56456B8F4081E3C44CCCE311DE151B67@zch01exm23.fsl.freescale.net>
References: <20090217222425.GA18801@ovro.caltech.edu> <D999D051-E5A2-4915-893D-E3384EC312A4@kernel.crashing.org> <7DF0AF56456B8F4081E3C44CCCE311DE1519A3@zch01exm23.fsl.freescale.net> <C04B22C6-BCE8-4D99-A160-22F8846C8209@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Ira Snyder" <iws@ovro.caltech.edu>,
	"Arnd Bergmann" <arnd@arndb.de>,
	"Jan-Bernd Themann" <THEMANN@de.ibm.com>, <netdev@vger.kernel.org>,
	"Rusty Russell" <rusty@rustcorp.com.au>,
	<linux-kernel@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
To: "Kumar Gala" <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:60347 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506AbZBTDo7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 22:44:59 -0500
Content-class: urn:content-classes:message
In-Reply-To: <C04B22C6-BCE8-4D99-A160-22F8846C8209@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

> -----Original Message-----
> From: Kumar Gala [mailto:galak@kernel.crashing.org] 
> Sent: Friday, February 20, 2009 0:52 AM
> To: Zang Roy-R61911
> Cc: Ira Snyder; Arnd Bergmann; Jan-Bernd Themann; 
> netdev@vger.kernel.org; Rusty Russell; 
> linux-kernel@vger.kernel.org; linuxppc-dev@ozlabs.org
> Subject: Re: [RFC v1] virtio: add virtio-over-PCI driver
> 
> 
> On Feb 19, 2009, at 12:13 AM, Zang Roy-R61911 wrote:
> 
> >
> >
> >> -----Original Message-----
> >> From:
> >> linuxppc-dev-bounces+tie-fei.zang=freescale.com@ozlabs.org
> >> [mailto:linuxppc-dev-bounces+tie-fei.zang=freescale.com@ozlabs
> >> .org] On Behalf Of Kumar Gala
> >> Sent: Thursday, February 19, 2009 0:47 AM
> >> To: Ira Snyder
> >> Cc: Arnd Bergmann; Jan-Bernd Themann; netdev@vger.kernel.org;
> >> Rusty Russell; linux-kernel@vger.kernel.org; 
> linuxppc-dev@ozlabs.org
> >> Subject: Re: [RFC v1] virtio: add virtio-over-PCI driver
> >>
> >>
> >> On Feb 17, 2009, at 4:24 PM, Ira Snyder wrote:
> >>
> >>>
> >>> Documentation/virtio-over-PCI.txt     |   61 ++
> >>> arch/powerpc/boot/dts/mpc834x_mds.dts |    7 +
> >>
> >> we'll have to review the .dts and expect a documentation update for
> >> the node.  But that's pretty minor at this point.
> >>
> >>> drivers/virtio/Kconfig                |   22 +
> >>> drivers/virtio/Makefile               |    2 +
> >>> drivers/virtio/vop.h                  |  119 ++
> >>> drivers/virtio/vop_fsl.c              | 1911
> >> ++++++++++++++++++++++++
> >>> +++++++++
> >>
> >> make this vop_fsl_mpc83xx.c or something along those lines.
> > why?
> 
> so we can deal with 85xx as well. 
After some modificaiton, the driver should be used on 85xx.
For 85xx, most of the cases are for pci express.

>  We just need to isolate the 83xx  
> specific bits (message usage)
Yes.
Roy
