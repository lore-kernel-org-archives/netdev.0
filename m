From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 09/71] smsc: Move the SMC (SMSC) drivers
Date: Sun, 31 Jul 2011 00:17:34 -0700
Message-ID: <CAL3LdT5xW9pK+dDeB+h9YhHfT4nqpbk0jRyU8M_Zei-H7AqGMg@mail.gmail.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1312082850-24914-10-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Nicolas Pitre <nico@fluxnic.net>,
	Donald Becker <becker@scyld.com>, Erik Stahlman <erik@vt.edu>,
	Dustin McIntire <dustin@sensoria.com>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	David Hinds <dahinds@users.sourceforge.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60206 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185Ab1GaHRf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2011 03:17:35 -0400
Received: by fxh19 with SMTP id 19so3537756fxh.19
        for <netdev@vger.kernel.org>; Sun, 31 Jul 2011 00:17:34 -0700 (PDT)
In-Reply-To: <1312082850-24914-10-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 30, 2011 at 20:26, Jeff Kirsher <jeffrey.t.kirsher@intel.co=
m> wrote:
> Moves the SMC (SMSC) drivers into drivers/net/ethernet/smsc/ and the
> necessary Kconfig and Makefile changes. =C2=A0Also did some cleanup
> of NET_VENDOR_SMC Kconfig tag for the 8390 based drivers.
>
> CC: Nicolas Pitre <nico@fluxnic.net>
> CC: Donald Becker <becker@scyld.com>
> CC: Erik Stahlman <erik@vt.edu>
> CC: Dustin McIntire <dustin@sensoria.com>
> CC: Steve Glendinning <steve.glendinning@smsc.com>
> CC: David Hinds <dahinds@users.sourceforge.net>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> =C2=A0MAINTAINERS =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0| =C2=A0 =C2=A06 +-
> =C2=A0drivers/net/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=
=A0105 ----------------
> =C2=A0drivers/net/Makefile =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0=
 =C2=A07 -
> =C2=A0drivers/net/ethernet/8390/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 21 +---
> =C2=A0drivers/net/ethernet/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A01 +
> =C2=A0drivers/net/ethernet/Makefile =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A01 +
> =C2=A0drivers/net/ethernet/smsc/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0128 ++++++++++++++++++++
> =C2=A0drivers/net/ethernet/smsc/Makefile =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 11 ++
> =C2=A0drivers/net/{ =3D> ethernet/smsc}/epic100.c =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0| =C2=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet/smsc}/smc911x.c =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0| =C2=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet/smsc}/smc911x.h =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0| =C2=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet/smsc}/smc9194.c =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0| =C2=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet/smsc}/smc9194.h =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0| =C2=A0 =C2=A00
> =C2=A0.../net/{pcmcia =3D> ethernet/smsc}/smc91c92_cs.c =C2=A0 =C2=A0=
| =C2=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet/smsc}/smc91x.c =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 | =C2=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet/smsc}/smc91x.h =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 | =C2=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet/smsc}/smsc911x.c =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 | =C2=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet/smsc}/smsc911x.h =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 | =C2=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet/smsc}/smsc9420.c =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 | =C2=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet/smsc}/smsc9420.h =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 | =C2=A0 =C2=A00
> =C2=A0drivers/net/pcmcia/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 11 --
> =C2=A0drivers/net/pcmcia/Makefile =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A01 -
> =C2=A022 files changed, 148 insertions(+), 144 deletions(-)
> =C2=A0create mode 100644 drivers/net/ethernet/smsc/Kconfig
> =C2=A0create mode 100644 drivers/net/ethernet/smsc/Makefile
> =C2=A0rename drivers/net/{ =3D> ethernet/smsc}/epic100.c (100%)
> =C2=A0rename drivers/net/{ =3D> ethernet/smsc}/smc911x.c (100%)
> =C2=A0rename drivers/net/{ =3D> ethernet/smsc}/smc911x.h (100%)
> =C2=A0rename drivers/net/{ =3D> ethernet/smsc}/smc9194.c (100%)
> =C2=A0rename drivers/net/{ =3D> ethernet/smsc}/smc9194.h (100%)
> =C2=A0rename drivers/net/{pcmcia =3D> ethernet/smsc}/smc91c92_cs.c (1=
00%)
> =C2=A0rename drivers/net/{ =3D> ethernet/smsc}/smc91x.c (100%)
> =C2=A0rename drivers/net/{ =3D> ethernet/smsc}/smc91x.h (100%)
> =C2=A0rename drivers/net/{ =3D> ethernet/smsc}/smsc911x.c (100%)
> =C2=A0rename drivers/net/{ =3D> ethernet/smsc}/smsc911x.h (100%)
> =C2=A0rename drivers/net/{ =3D> ethernet/smsc}/smsc9420.c (100%)
> =C2=A0rename drivers/net/{ =3D> ethernet/smsc}/smsc9420.h (100%)
>

=2E..[snip] ...

> diff --git a/drivers/net/ethernet/smsc/Kconfig b/drivers/net/ethernet=
/smsc/Kconfig
> new file mode 100644
> index 0000000..dbb3069
> --- /dev/null
> +++ b/drivers/net/ethernet/smsc/Kconfig
> @@ -0,0 +1,128 @@
> +#
> +# Western Digital/SMC network device configuration
> +#
> +
> +config NET_VENDOR_SMSC
> + =C2=A0 =C2=A0 =C2=A0 bool "SMC (SMSC)/Western Digital devices"
> + =C2=A0 =C2=A0 =C2=A0 depends on ARM || ISA || MAC || ARM || MIPS ||=
 M32R || SUPERH || \
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BLACKFIN || MN1030=
0 || COLDFIRE || PCI || PCMCIA
> + =C2=A0 =C2=A0 =C2=A0 ---help---
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 If you have a network (Ethernet) card b=
elonging to this class, say Y
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 and read the Ethernet-HOWTO, available =
from
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 <http://www.tldp.org/docs.html#howto>.
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 Note that the answer to this question d=
oesn't directly affect the
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 kernel: saying N will just cause the co=
nfigurator to skip all
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 the questions about SMC/Western Digital=
 cards. If you say Y, you will
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 be asked for your specific card in the =
following questions.
> +
> +config SMC9194
> + =C2=A0 =C2=A0 =C2=A0 tristate "SMC 9194 support"
> + =C2=A0 =C2=A0 =C2=A0 depends on NET_VENDOR_SMSC && (ISA || MAC && B=
ROKEN)
> + =C2=A0 =C2=A0 =C2=A0 select CRC32
> + =C2=A0 =C2=A0 =C2=A0 ---help---
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 This is support for the SMC9xxx based E=
thernet cards. Choose this
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 option if you have a DELL laptop with t=
he docking station, or
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 another SMC9192/9194 based chipset. =C2=
=A0Say Y if you want it compiled
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 into the kernel, and read the file
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 <file:Documentation/networking/smc9.txt=
> and the Ethernet-HOWTO,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 available from <http://www.tldp.org/doc=
s.html#howto>.
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 To compile this driver as a module, cho=
ose M here. The module
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 will be called smc9194.
> +
> +config SMC91X
> + =C2=A0 =C2=A0 =C2=A0 tristate "SMC 91C9x/91C1xxx support"
> + =C2=A0 =C2=A0 =C2=A0 select CRC32
> + =C2=A0 =C2=A0 =C2=A0 select MII
> + =C2=A0 =C2=A0 =C2=A0 depends on NET_VENDOR_SMSC && (ARM || M32R || =
SUPERH || \
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 MIPS || BLACKFIN |=
| MN10300 || COLDFIRE)
> + =C2=A0 =C2=A0 =C2=A0 ---help---
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 This is a driver for SMC's 91x series o=
f Ethernet chipsets,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 including the SMC91C94 and the SMC91C11=
1. Say Y if you want it
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 compiled into the kernel, and read the =
file
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 <file:Documentation/networking/smc9.txt=
> =C2=A0and the Ethernet-HOWTO,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 available from =C2=A0<http://www.tldp.o=
rg/docs.html#howto>.
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 This driver is also available as a modu=
le ( =3D code which can be
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 inserted in and removed from the runnin=
g kernel whenever you want).
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 The module will be called smc91x. =C2=A0=
If you want to compile it as a
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 module, say M here and read <file:Docum=
entation/kbuild/modules.txt>.
> +
> +config PCMCIA_SMC91C92
> + =C2=A0 =C2=A0 =C2=A0 tristate "SMC 91Cxx PCMCIA support"
> + =C2=A0 =C2=A0 =C2=A0 depends NET_VENDOR_SMSC && PCMCIA

=46ound a typo, should be "DEPENDS ON ..." , I will fix up the patch on=
 my tree.

--=20
Cheers,
Jeff
