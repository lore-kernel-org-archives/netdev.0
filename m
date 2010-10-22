From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] gianfar: Fix crashes on RX path (Was Re: [Bugme-new]
	[Bug 19692] New: linux-2.6.36-rc5 crash with gianfar ethernet at
	full line rate traffic)
Date: Fri, 22 Oct 2010 07:03:26 +0000
Message-ID: <20101022070326.GB7036@ff.dom.local>
References: <20101010103236.GA1919@del.dom.local> <20101015085853.GA8091@ff.dom.local> <AANLkTinAj=9-RqNA6xKc_5ONz2hPMRGM8uJ2Xy7XJVdr@mail.gmail.com> <20101016194815.GA1894@del.dom.local> <AANLkTi=08Myz1=XOHkGJWTdyC8vK+y+zf0UQhjxUi=qC@mail.gmail.com> <20101019100636.GA9246@ff.dom.local> <AANLkTimakJjwL9v2Ztpce3Xnjb_r5XB=rGoJc9pZKE12@mail.gmail.com> <1287728048.9059.124.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: emin ak <eminak71@gmail.com>, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Anton Vorontsov <avorontsov@mvista.com>,
	Andy Fleming <afleming@freescale.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:64944 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752803Ab0JVHDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 03:03:32 -0400
Received: by bwz11 with SMTP id 11so262785bwz.19
        for <netdev@vger.kernel.org>; Fri, 22 Oct 2010 00:03:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1287728048.9059.124.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 22, 2010 at 08:14:08AM +0200, Eric Dumazet wrote:
> Le vendredi 22 octobre 2010 ?? 08:42 +0300, emin ak a =E9crit :
> > Hi Jarek;
> >=20
> > > Maybe for now let's try to get and see this type 1 again? Since t=
he
> > > recycle path is suspicious a bit to me, probably limiting memory =
or
> > > slowing tx (maybe different mtus on eth0 and 1) under heavy multi=
 cpu
> > > load might help.
> > >
> >=20
> > I'll do my best with your recommended test conditions. I have reser=
ved
> > a machine and two ports of  hw packet generator, now we'll see if t=
his
> > error will occur again or not. (But I'am not sure if I want to see =
it
> > again:)
>=20
> Really this rx recycle affair is more than suspicious to me too.
>=20
> Is it really worth the pain ?
>=20
> Are MTU changes handled correctly ? ( must flush rx_recycle queue...)
>=20
> Using a single rx_recycle queue in a supposed multiqueue driver makes
> absolutely _no_ sense to me. This adds an artificial contention point=
=2E
>=20

Yes, the design/need of this rx_recycle queue should be reconsidered.
But we don't know if the (other?) bug seen by Emin was connected, so
it would be better to try to reproduce it without too many changes.

Jarek P.
