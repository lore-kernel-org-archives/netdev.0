From: Subrata Modak <subrata@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 0/7] can: CAN network device driver interface and
	drivers
Date: Tue, 12 May 2009 16:29:36 +0530
Message-ID: <1242125977.5911.40.camel@subratamodak.linux.ibm.com>
References: <20090512094631.26592.81609.sendpatchset@subratamodak.linux.ibm.com>
	 <4A094833.7030006@grandegger.com>  <4A095373.9010205@volkswagen.de>
Reply-To: subrata@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	ltp-list <ltp-list@lists.sf.net>, netdev <netdev@vger.kernel.org>
To: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:39823 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751834AbZELK7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 06:59:39 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4CArc0T024606
	for <netdev@vger.kernel.org>; Tue, 12 May 2009 04:53:38 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4CAxehQ230310
	for <netdev@vger.kernel.org>; Tue, 12 May 2009 04:59:40 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4CAxd3K029910
	for <netdev@vger.kernel.org>; Tue, 12 May 2009 04:59:40 -0600
In-Reply-To: <4A095373.9010205@volkswagen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Oliver,

On Tue, 2009-05-12 at 12:46 +0200, Oliver Hartkopp wrote:
> Wolfgang Grandegger wrote:
> > Subrata Modak wrote:
> >> Hi Oliver/Wolfgang,
> >>
> >>> Hello,
> >>>
> >>> here comes v2 of the patch series posted some time ago. See
> >>>
> >>>  http://marc.info/?l=3Dlinux-netdev&m=3D123507025810612&w=3D4.
> >>>
> >>> Changes since v1:
> > [...]
> >> Would you also like to send a patch to update the testcases for CA=
N in LTP
> >> (http://ltp.cvs.sourceforge.net/viewvc/ltp/ltp/testcases/network/c=
an/filter-tests/) ?
> >> These tests were originally picked up from:
> >> http://svn.berlios.de/wsvn/socketcan/trunk/test/?rev=3D877&sc=3D1
> >
> > The existing tests uses the vcan (virtual CAN) driver, which is not
> > affected by these patches. Are you thinking about tests using *real=
* CAN
> > devices?
> >
>=20
> Hi Subrata,
>=20
> indeed extending the test-cases to the real CAN drivers would urge yo=
u=20
> to add a least
> two hardware CAN-interfaces to your test system and wire them correct=
ly=20
> with the
> appropriate termination.
> It's like having *all* ethernet cards available in your linux box to=20
> test them ;-)
> Some of these CAN controllers are only available as an on-chip device
> (e.g. for some PowerPC CPUs).

That makes great sense, as our team uses PowerPC heavily as their test
hardware.

I would also like to have tests added to LTP even if i myself do not
have the hardware to test it. If there=C2=B4s something of significant
importance to a group of people/community, for which tests need to
exist, then they can make into LTP, provided you have tested them and
Acked them, and somebody else has not complained of any build/run
breaks.

>=20
> If there is some room for LTP improvements, i would tend to create so=
me=20
> more test-cases
> for the networklayer stuff in linux/net/can using the existent virtua=
l=20
> CAN driver.

Please go ahead.

Regards--
Subrata

>=20
> Best regards,
> Oliver
>=20

