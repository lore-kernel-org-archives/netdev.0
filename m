From: Wolfgang Walter <linux@stwm.de>
Subject: Re: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Wed, 23 Oct 2013 13:33:14 +0200
Message-ID: <1748378.n7GIUzQXTX@h2o.as.studentenwerk.mhn.de>
References: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de> <20131022.154638.1989281525248160764.davem@davemloft.net> <20131023081255.GB10148@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:47065 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752572Ab3JWLdQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Oct 2013 07:33:16 -0400
In-Reply-To: <20131023081255.GB10148@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 23. Oktober 2013, 10:12:55 schrieb Steffen Klassert:
> On Tue, Oct 22, 2013 at 03:46:38PM -0400, David Miller wrote:
> > From: Wolfgang Walter <linux@stwm.de>
> > Date: Tue, 22 Oct 2013 21:07:41 +0200
> >=20
> > > Am Mittwoch, 2. Oktober 2013, 00:20:02 schrieb Hannes Frederic So=
wa:
> > >> On Tue, Oct 01, 2013 at 06:39:32PM +0200, Wolfgang Walter wrote:
> > >> > All network traffic over the router become slow and sluggish. =
If one
> > >> > pings
> > >> > the router there is a packet loss. After about 2 minutes the t=
raffic
> > >> > completely stalls for about 1 minute. Then it works again as i=
n the
> > >> > beginning to then stall again. And so on.
> > >>=20
> > >> Maybe dropwatch can give a first hint?
> > >=20
> > > I finally found the problem:
> > >=20
> > > In 3.10.x and 3.11.x the value of /proc/sys/net/ipv4/xfrm4_gc_thr=
esh is
> > > 1024.
> > >=20
> > > It is much higher in 3.4.x. If I increase this value in 3.10.x to=
 the
> > > one I
> > > see on 3.4.x all works fine with 3.10.x
> >=20
> > Steffen, here is yet another report about this issue.
> >=20
> > I think we should resolve this soon, even bumping it to 2048 or 409=
6
> > and leaving it at that would be I think acceptable.
>=20
> Yes, of course. Let's use 4096 as the default for ipv4 and ipv6.
> I'll take care of it next week.
>=20

I don't know what this value actually means. But on 3.4.x it is much hi=
gher.=20
On a machine with 512MB ram it is 32768, on a machine with 1GB ram it i=
s=20
262144 and with 16GB ram it is 4194304.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
