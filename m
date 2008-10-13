From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [BUILD_FAILURE] 2.6.27-git2 - allyesconfig on powerpc selects
	CONFIG_INTEL_IOATDMA=y
Date: Mon, 13 Oct 2008 14:26:31 +0300
Message-ID: <20081013112631.GD29938@cs181140183.pp.htv.fi>
References: <20081013101559.GA14372@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, apw@shadowen.org,
	linuxppc-dev@ozlabs.org, sam@ravnborg.org,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	Brice Goglin <brice@myri.com>,
	Jeff Garzik <jgarzik@redhat.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:49015 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760012AbYJML1e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2008 07:27:34 -0400
Content-Disposition: inline
In-Reply-To: <20081013101559.GA14372@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 13, 2008 at 03:45:59PM +0530, Kamalesh Babulal wrote:
> Hi,
>=20
>    2.6.27-git2 kernel build fails, while building the kernel with
> allyesconfig option. The allyesconfig selects CONFIG_INTEL_IOATDMA=3D=
y
>=20
> CC   drivers/dma/ioat_dca.o
> drivers/dma/ioat_dca.c: In function =C3=A2=C2=80=C2=98dca_enabled_in_=
bios=C3=A2=C2=80=C2=99:
> drivers/dma/ioat_dca.c:81: error: implicit declaration of function =C3=
=A2=C2=80=C2=98cpuid_eax=C3=A2=C2=80=C2=99
> drivers/dma/ioat_dca.c: In function =C3=A2=C2=80=C2=98system_has_dca_=
enabled=C3=A2=C2=80=C2=99:
> drivers/dma/ioat_dca.c:91: error: implicit declaration of function =C3=
=A2=C2=80=C2=98boot_cpu_has=C3=A2=C2=80=C2=99
> drivers/dma/ioat_dca.c:91: error: =C3=A2=C2=80=C2=98X86_FEATURE_DCA=C3=
=A2=C2=80=C2=99 undeclared (first use in this function)
> drivers/dma/ioat_dca.c:91: error: (Each undeclared identifier is repo=
rted only once
> drivers/dma/ioat_dca.c:91: error: for each function it appears in.)
> drivers/dma/ioat_dca.c: In function =C3=A2=C2=80=C2=98ioat_dca_get_ta=
g=C3=A2=C2=80=C2=99:
> drivers/dma/ioat_dca.c:190: error: implicit declaration of function =C3=
=A2=C2=80=C2=98cpu_physical_id=C3=A2=C2=80=C2=99
> make[2]: *** [drivers/dma/ioat_dca.o] Error 1
> make[1]: *** [drivers/dma] Error 2
> make: *** [drivers] Error 2
>...

Thanks for the report, the MYRI10GE and IXGBE commits that introduced=20
the select's are really broken.

=46or fixing it I need to know the intended semantics.

Brian, Jesse, is it OK to limit the drivers to m with=20
CONFIG_INTEL_IOATDMA=3Dm ?

cu
Adrian

--=20

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

