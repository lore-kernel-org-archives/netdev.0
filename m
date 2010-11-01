From: "Joseph Chang" <joseph_chang@mail.davicom.com.tw>
Subject: RE: About the Davicom PHY in drivers/net/phy in Linux kernel
Date: Mon, 1 Nov 2010 10:27:25 +0800
Message-ID: <20101101022039.5EF1F5F951@mail.davicom.com.tw>
References: <50FD90C65C53FB45BADEEBCD84FF07F202A62479@ATCPCS06.andestech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <afleming@freescale.com>, <jeff@garzik.org>,
	<f.rodo@til-technologies.fr>
To: <macpaul@andestech.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from davicom.com.tw ([202.39.11.22]:39523 "EHLO mail.davicom.com.tw"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753816Ab0KAC1i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Oct 2010 22:27:38 -0400
In-Reply-To: <50FD90C65C53FB45BADEEBCD84FF07F202A62479@ATCPCS06.andestech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear MacPaul,

   1.Yes. I have downloaded it. And below is the know items.
  =20
     DM9161A
     cpu: Faraday A320 (arm920t) + Andes AG101 (NDS32) ;SoC
     OS: Linux: 2.6.32
     Actions:
       - davicom.c             // Download from LXR
       - include-linux-mii.h   // Download from LXR

   2.Your quote is right. Please tell us the test result.

   3.I have a question for you,
   Where is your company? I browse for andestech, And found that andest=
ech located at
    SiSoft SIPP Center! (Address: 2F, No.1, Li-Hsin First Road, Science=
-Based Industrial Park)=20
    Is it right?=20

Best Regards,
Joseph CHANG=20
System Application Engineering Division=20
Davicom Semiconductor, Inc.=20
No. 6 Li-Hsin Rd. VI, Science-Based Park,=20
Hsin-Chu, Taiwan.=20
Tel: 886-3-5798797 Ex 8534
=46ax: 886-3-5646929=20
Web: http://www.davicom.com.tw=20

-----Original Message-----
=46rom: macpaul@andestech.com [mailto:macpaul@andestech.com]=20
Sent: Friday, October 29, 2010 3:47 PM
To: joseph_chang@mail.davicom.com.tw; netdev@vger.kernel.org
Cc: afleming@freescale.com; jeff@garzik.org; f.rodo@til-technologies.fr
Subject: RE: About the Davicom PHY in drivers/net/phy in Linux kernel

Hi Joseph,

I just followed up your suggestion in previous mail, let me quote them =
here:

# quote
The recommend is changed to be as below:
 err =3D phy_write(phydev, MII_BMCR, BMCR_RESET);
    //err =3D phy_write(phydev, MII_BMCR, BMCR_ISOLATE);
   err =3D phy_write(phydev, MII_DM9161_SCR, MII_DM9161_SCR_INIT);
   err =3D phy_write(phydev, MII_DM9161_10BTCSR, MII_DM9161_10BTCSR_INI=
T);
  // err =3D phy_write(phydev, MII_NWAYTEST, 0x10);
    err =3D phy_write(phydev, MII_BMCR, BMCR_ANENABLE | BMCR_ANRESTART)=
;
  *Note: Added a PHY reset command.
# end quote
>=20
>  * =3D=3D > Would you tell us your:
> =EF=83=98	CPU =3D ?
SoC: Faraday A320 (arm920t) / Andes AG101 (NDS32)
> =EF=83=98	Linux Kernel version=3D ?
Linux: 2.6.32
>       I will like to download the same source code from LXR.
>       And can check more detail for you.

I've believed that you have download the source already. :-)



--=20
This message has been scanned for viruses and
dangerous content by MailScanner, and is
believed to be clean.


