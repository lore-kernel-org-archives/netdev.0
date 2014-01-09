From: Tama <pkm_munot@yahoo.co.in>
Subject: Device tree binding for Managed Switch
Date: Thu, 9 Jan 2014 14:12:24 +0800 (SGT)
Message-ID: <1389247944.40578.YahooMailNeo@web193105.mail.sg3.yahoo.com>
Reply-To: Tama <pkm_munot@yahoo.co.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm4-vm3.bullet.mail.sg3.yahoo.com ([106.10.148.130]:35723 "EHLO
	nm4-vm3.bullet.mail.sg3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751431AbaAIGTY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 01:19:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Hi All,

I am new to this mailing this. I am using IMX28 based custom designed b=
oard, based on TQ Components TQMA28 module. In our board we are using K=
SZ8863 and KSZ8895 managed switches instead of standard phy device. How=
 to add support for managed switch in device tree.

I am new to device tree configuration. At present I have got
=A0=A0=A0=A0=A0=A0=A0 mac0: ethernet@800f0000 {
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 compatible =3D "fsl,imx28-fec";
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 reg =3D <0x800f0000 0x4000>;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 interrupts =3D <101>;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 status =3D "disabled";
=A0=A0=A0=A0=A0=A0=A0 };

=A0=A0=A0=A0=A0=A0=A0 mac1: ethernet@800f4000 {
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 compatible =3D "fsl,imx28-fec";
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 reg =3D <0x800f4000 0x4000>;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 interrupts =3D <102>;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 status =3D "disabled";
=A0=A0=A0=A0=A0=A0=A0 };

In my device tree imx28.dtsi and in imx28-mba28.dts I have got=20

=A0=A0=A0=A0=A0=A0=A0 /* FCC1 management to switch */
=A0=A0=A0=A0=A0=A0=A0 eth0: ethernet@800f0000 {
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 device_type =3D "network";
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 compatible =3D "micrel,ksz8895";
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 reg =3D <0x800f0000 0x4000>;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 local-mac-address =3D [ 00 01 02 03 0=
4 07 ];
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 interrupts =3D <101>;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 fixed-link =3D <1 1 1000 0 0>;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 phy-handle =3D <&phy0>;=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=20
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 phy0: phy@0 {
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 fixed-link;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 full-duplex;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 speed =3D <1000>;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 };
=A0=A0=A0=A0=A0=A0=A0 };=A0=A0=A0=A0=A0=A0=20

=A0=A0=A0=A0=A0=A0=A0 /* FCC1 management to switch */
=A0=A0=A0=A0=A0=A0=A0 eth1: ethernet@800f4000 {
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 device_type =3D "network";
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 compatible =3D "micrel, ksz8895";
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 reg =3D <0x800f0000 0x4000>;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 local-mac-address =3D [ 00 01 02 03 0=
4 08 ];
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 interrupts =3D <102>;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 fixed-link =3D <1 1 1000 0 0>;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 phy-handle =3D <&phy1>;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 phy1: phy@1 {
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 fixed-link;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 full-duplex;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 speed =3D <1000>;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 };=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=20
=A0=A0=A0=A0=A0=A0=A0 };


I read threads on this mailing list and modified the device tree for ma=
naged switch. I am not 100% sure if my configuration is correct. When t=
he kernel is booting it is scanning for phy devices and as it doesnt ge=
t a phy device id it doesnt register any device.

Can some one please share information on how to configure the device tr=
ee for device and not a phy.

Thanks
Pritam
