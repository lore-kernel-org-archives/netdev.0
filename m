From: John Linn <John.Linn@xilinx.com>
Subject: RE: [PATCH] [V2] net: emaclite: adding MDIO and phy lib support
Date: Tue, 9 Feb 2010 08:57:10 -0700
Message-ID: <7a99fdf2-8fd0-4fd0-9cbb-fe6c87d5f50e@SG2EHSMHS015.ehs.local>
References: <1265409646-11882-1-git-send-email-john.linn@xilinx.com> <260b8801-53bd-44fe-a6b8-7d1d0f56fef5@SG2EHSMHS011.ehs.local> <fa686aa41002090745x19d569acx3b50e8078ebb16f7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	<jgarzik@pobox.com>, <jwboyer@linux.vnet.ibm.com>,
	<john.williams@petalogix.com>,
	"Sadanand Mutyala" <sadanan@xilinx.com>
To: "Grant Likely" <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sg2ehsobe002.messaging.microsoft.com ([207.46.51.76]:11473 "EHLO
	SG2EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754531Ab0BIP54 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2010 10:57:56 -0500
Content-Class: urn:content-classes:message
In-Reply-To: <fa686aa41002090745x19d569acx3b50e8078ebb16f7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: glikely@secretlab.ca [mailto:glikely@secretlab.ca] On Behalf Of=
 Grant Likely
> Sent: Tuesday, February 09, 2010 8:45 AM
> To: John Linn
> Cc: netdev@vger.kernel.org; linuxppc-dev@ozlabs.org; jgarzik@pobox.co=
m; jwboyer@linux.vnet.ibm.com;
> john.williams@petalogix.com; Sadanand Mutyala
> Subject: Re: [PATCH] [V2] net: emaclite: adding MDIO and phy lib supp=
ort
>=20
> On Mon, Feb 8, 2010 at 7:09 AM, John Linn <John.Linn@xilinx.com> wrot=
e:
> >> -----Original Message-----
> >> From: John Linn [mailto:john.linn@xilinx.com]
> >> Sent: Friday, February 05, 2010 3:41 PM
> >> To: netdev@vger.kernel.org; linuxppc-dev@ozlabs.org;
> > jgarzik@pobox.com; grant.likely@secretlab.ca;
> >> jwboyer@linux.vnet.ibm.com
> >> Cc: john.williams@petalogix.com; John Linn; Sadanand Mutyala
> >> Subject: [PATCH] [V2] net: emaclite: adding MDIO and phy lib suppo=
rt
> >>
> >> These changes add MDIO and phy lib support to the driver as the
> >> IP core now supports the MDIO bus.
> >>
> >> The MDIO bus and phy are added as a child to the emaclite in the
> > device
> >> tree as illustrated below.
> >>
> >> mdio {
> >> =A0 =A0 =A0 #address-cells =3D <1>;
> >> =A0 =A0 =A0 #size-cells =3D <0>;
> >> =A0 =A0 =A0 compatible =3D "xlnx,emaclite-mdio";
> >> =A0 =A0 =A0 phy0: phy@7 {
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg =3D <7>;
> >> =A0 =A0 =A0 } ;
> >> }
>=20
> You misunderstood me about the compatible property.  You don't need a
> compatible prop in the mdio node because it is *alwasy* a child of th=
e
> emaclite node, and the emaclite driver knows to go looking for it (ie=
=2E
> it is a part of the device).

OK, now I see, sorry for my denseness there.

>=20
> What I want to see is a compatible value in the phy@7 node for the
> make & model of the phy.

Makes more sense.

>=20
> Otherwise, looks good to me.  Fix the mutex timeout problem and then
> you can add my acked-by line to the patch.

Will spin V3 patch with fixes and add your ack, appreciate the help and=
 your patience.

- John

>=20
> Cheers,
> g.


This email and any attachments are intended for the sole use of the nam=
ed recipient(s) and contain(s) confidential information that may be pro=
prietary, privileged or copyrighted under applicable law. If you are no=
t the intended recipient, do not read, copy, or forward this email mess=
age or any attachments. Delete this email message and any attachments i=
mmediately.


