From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [V5] net: emaclite: adding MDIO and phy lib support
Date: Mon, 15 Feb 2010 21:53:26 -0800 (PST)
Message-ID: <20100215.215326.250123543.davem@davemloft.net>
References: <38677d6a-3f33-483c-8fbe-5f5c46d70140@VA3EHSMHS027.ehs.local>
	<fa686aa41002111440x699b6b1ck97b14002ee9fe7b1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: john.linn@xilinx.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	jwboyer@linux.vnet.ibm.com, john.williams@petalogix.com,
	Sadanand.Mutyala@xilinx.com
To: grant.likely@secretlab.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41354
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752947Ab0BPFxM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2010 00:53:12 -0500
In-Reply-To: <fa686aa41002111440x699b6b1ck97b14002ee9fe7b1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Grant Likely <grant.likely@secretlab.ca>
Date: Thu, 11 Feb 2010 15:40:24 -0700

> On Thu, Feb 11, 2010 at 3:12 PM, John Linn <john.linn@xilinx.com> wro=
te:
>> These changes add MDIO and phy lib support to the driver as the
>> IP core now supports the MDIO bus.
>>
>> The MDIO bus and phy are added as a child to the emaclite in the dev=
ice
>> tree as illustrated below.
>>
>> mdio {
>> =A0 =A0 =A0 =A0#address-cells =3D <1>;
>> =A0 =A0 =A0 =A0#size-cells =3D <0>;
>> =A0 =A0 =A0 =A0phy0: phy@7 {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0compatible =3D "marvell,88e1111";
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg =3D <7>;
>> =A0 =A0 =A0 =A0} ;
>> }
>>
>> Signed-off-by: Sadanand Mutyala <Sadanand.Mutyala@xilinx.com>
>> Signed-off-by: John Linn <john.linn@xilinx.com>
>=20
> Acked-by: Grant Likely <grant.likely@secretlab.ca>

Applied.
