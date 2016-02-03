From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Keystone 2 boards boot failure
Date: Wed, 03 Feb 2016 21:41:59 +0100
Message-ID: <4454564.GTcE4YArgu@wuerfel>
References: <56B0DE61.2000704@ti.com> <1888105.8DsfvU3cAo@wuerfel> <56B22DC4.3070100@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
	"Franklin S Cooper Jr." <fcooper@ti.com>, netdev@vger.kernel.org,
	w-kwok2@ti.com, davem@davemloft.net
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.134]:53073 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932088AbcBCUmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 15:42:10 -0500
In-Reply-To: <56B22DC4.3070100@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 03 February 2016 11:41:40 Murali Karicheri wrote:
> > 
> > This looks wrong: I was getting the build warnings originally
> > because of 64-bit dma_addr_t, and that should be the only way that
> > this driver can operate, because in some configurations on keystone
> > there is no memory below 4GB, and there is no dma-ranges property
> > in the DT that shifts around the start of the DMA addresses.
> Arnd,
> 
> Why do think so? I see in arch/arm/boot/dts/keystone.dtsi
> 
>         soc {
>                 #address-cells = <1>;
>                 #size-cells = <1>;
>                 compatible = "ti,keystone","simple-bus";
>                 interrupt-parent = <&gic>;
>                 ranges = <0x0 0x0 0x0 0xc0000000>;
>                 dma-ranges = <0x80000000 0x8 0x00000000 0x80000000>;
> 
> AFAIK, On Keystone, dma address is 32 bit and Physical DDR address is
> 64 bit (actually 36 bit, LPAE address). The conversion happens based on
> pfn_offset which is calculated based on the above dma-range property.

My mistake, see my other reply.
 


	Arnd
