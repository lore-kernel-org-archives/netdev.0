From: Sebastien BLAVIER <sebastien.blavier@medianesysteme.com>
Subject: MPC885 spi: fsl-spi and SCC2 : Allow dynamic allocation of CPM1 pRAM
Date: Wed, 6 May 2015 23:18:40 +0000
Message-ID: <9C239FD147603C458A197774921522B132937FE4@ikhexmbxc02n01.ikhex.ikoula.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ikhexhub01.ex10.biz ([178.170.125.76]:47747 "EHLO smtp.ex10.biz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751034AbbEFXYH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 19:24:07 -0400
Content-Language: fr-FR
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Dear,


I would like to know if a patch of file spi_mpc8xxx.c exists to use SPI=
 and SCC2 on MPC885 for linux 2.6.35?


The start of driver fails  =3D> the function mpc8xxx_spi_cpm_get_pram i=
s KO due to :  spi_base_ofs =3D cpm_muram_alloc_fixed(iprop[2], 2);  =3D=
> spi_base_ofs invalid .


if i do this change spi_base_ofs =3D iprop[2], 2; in function mpc8xxx_s=
pi_cpm_get_pram, the driver is loaded but the SCC2 does not work any mo=
re and SPI does not work too.


Arch setup :=20
{CPM_PORTB, 28, CPM_PIN_OUTPUT},

{CPM_PORTB, 29, CPM_PIN_OUTPUT},

{CPM_PORTB, 30, CPM_PIN_OUTPUT},



My DTS below :
          cpm@9c0 {
              #address-cells =3D <1>;
              #size-cells =3D <1>;
              compatible =3D "fsl,mpc885-cpm", "fsl,cpm1";
=2E...
              spi: spi@aa0 {
                  #address-cells =3D <1>;
                  #size-cells =3D <0>;
                  cell-index =3D <0>;
                  compatible =3D "fsl,spi", "fsl,cpm1-spi";
                  reg =3D <0xaa0 0x12 0x3d80 0x30>;
		  interrupts =3D <5>;


S=E9bastien Blavier.