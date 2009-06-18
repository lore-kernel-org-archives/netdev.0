From: Subrata Modak <subrata@linux.vnet.ibm.com>
Subject: Re: [LTP] [PATCH v2 0/7] can: CAN network device driver
	interfaceand  drivers
Date: Thu, 18 Jun 2009 23:01:19 +0530
Message-ID: <1245346280.5041.30.camel@subratamodak.linux.ibm.com>
References: <20090512094631.26592.81609.sendpatchset@subratamodak.linux.ibm.com>
	 <4A094833 .7030006@grandegger.com>  <4A095373.9010205@volkswagen.de>
	 <1242125977.5911.40.camel@subratamodak.linux.ibm.com>
Reply-To: subrata@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ltp-list <ltp-list@lists.sf.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	netdev <netdev@vger.kernel.org>
To: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:55972 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751607AbZFRRbe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2009 13:31:34 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e5.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5IHPOSM011645
	for <netdev@vger.kernel.org>; Thu, 18 Jun 2009 13:25:24 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5IHVZv21425554
	for <netdev@vger.kernel.org>; Thu, 18 Jun 2009 13:31:36 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5IHVQ0c011346
	for <netdev@vger.kernel.org>; Thu, 18 Jun 2009 11:31:26 -0600
In-Reply-To: <1242125977.5911.40.camel@subratamodak.linux.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver,

You have anything for us now ?

Regards--
Subrata

On Tue, 2009-05-12 at 16:29 +0530, Subrata Modak wrote:=20
> Hi Oliver,
>=20
> On Tue, 2009-05-12 at 12:46 +0200, Oliver Hartkopp wrote:
> > Wolfgang Grandegger wrote:
> > > Subrata Modak wrote:
> > >> Hi Oliver/Wolfgang,
> > >>
> > >>> Hello,
> > >>>
> > >>> here comes v2 of the patch series posted some time ago. See
> > >>>
> > >>>  http://marc.info/?l=3Dlinux-netdev&m=3D123507025810612&w=3D4.
> > >>>
> > >>> Changes since v1:
> > > [...]
> > >> Would you also like to send a patch to update the testcases for =
CAN in LTP
> > >> (http://ltp.cvs.sourceforge.net/viewvc/ltp/ltp/testcases/network=
/can/filter-tests/) ?
> > >> These tests were originally picked up from:
> > >> http://svn.berlios.de/wsvn/socketcan/trunk/test/?rev=3D877&sc=3D=
1
> > >
> > > The existing tests uses the vcan (virtual CAN) driver, which is n=
ot
> > > affected by these patches. Are you thinking about tests using *re=
al* CAN
> > > devices?
> > >
> >=20
> > Hi Subrata,
> >=20
> > indeed extending the test-cases to the real CAN drivers would urge =
you=20
> > to add a least
> > two hardware CAN-interfaces to your test system and wire them corre=
ctly=20
> > with the
> > appropriate termination.
> > It's like having *all* ethernet cards available in your linux box t=
o=20
> > test them ;-)
> > Some of these CAN controllers are only available as an on-chip devi=
ce
> > (e.g. for some PowerPC CPUs).
>=20
> That makes great sense, as our team uses PowerPC heavily as their tes=
t
> hardware.
>=20
> I would also like to have tests added to LTP even if i myself do not
> have the hardware to test it. If there=C2=B4s something of significan=
t
> importance to a group of people/community, for which tests need to
> exist, then they can make into LTP, provided you have tested them and
> Acked them, and somebody else has not complained of any build/run
> breaks.
>=20
> >=20
> > If there is some room for LTP improvements, i would tend to create =
some=20
> > more test-cases
> > for the networklayer stuff in linux/net/can using the existent virt=
ual=20
> > CAN driver.
>=20
> Please go ahead.
>=20
> Regards--
> Subrata
>=20
> >=20
> > Best regards,
> > Oliver
> >=20
>=20
>=20
> ---------------------------------------------------------------------=
---------
> The NEW KODAK i700 Series Scanners deliver under ANY circumstances! Y=
our
> production scanning environment may not be a perfect world - but than=
ks to
> Kodak, there's a perfect scanner to get the job done! With the NEW KO=
DAK i700
> Series Scanner you'll get full speed at 300 dpi even with all image=20
> processing features enabled. http://p.sf.net/sfu/kodak-com
> _______________________________________________
> Ltp-list mailing list
> Ltp-list@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/ltp-list

