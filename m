From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [net-next-2.6 PATCH] can: SJA1000: generic OF platform bus driver
Date: Thu, 21 May 2009 22:42:07 -0600
Message-ID: <fa686aa40905212142n4a8c3caamb2f28eef036e3922@mail.gmail.com>
References: <4A143896.7050200@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	linuxppc-dev <Linuxppc-dev@ozlabs.org>,
	devicetree-discuss <devicetree-discuss@ozlabs.org>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:64275 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbZEVEm0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 00:42:26 -0400
Received: by yx-out-2324.google.com with SMTP id 3so924820yxj.1
        for <netdev@vger.kernel.org>; Thu, 21 May 2009 21:42:27 -0700 (PDT)
In-Reply-To: <4A143896.7050200@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2009 at 11:06 AM, Wolfgang Grandegger <wg@grandegger.co=
m> wrote:
> This patch adds a generic driver for SJA1000 chips on the OpenFirmwar=
e
> platform bus found on embedded PowerPC systems. You need a SJA1000 no=
de
> definition in your flattened device tree source (DTS) file similar to=
:
>
> =A0 can@3,100 {
> =A0 =A0 =A0 =A0 =A0 compatible =3D "philips,sja1000";
> =A0 =A0 =A0 =A0 =A0 reg =3D <3 0x100 0x80>;
> =A0 =A0 =A0 =A0 =A0 clock-frequency =3D <8000000>;
> =A0 =A0 =A0 =A0 =A0 cdr-reg =3D <0x48>;
> =A0 =A0 =A0 =A0 =A0 ocr-reg =3D <0x0a>;
> =A0 =A0 =A0 =A0 =A0 interrupts =3D <2 0>;
> =A0 =A0 =A0 =A0 =A0 interrupt-parent =3D <&mpic>;
> =A0 };

This new binding must be documented in Documentation/powerpc/dts-bindin=
gs

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
