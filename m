From: Wolfgang Walter <linux@stwm.de>
Subject: Re: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Wed, 23 Oct 2013 18:05:22 +0200
Message-ID: <2007014.RQqn1EBPtM@h2o.as.studentenwerk.mhn.de>
References: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de> <1748378.n7GIUzQXTX@h2o.as.studentenwerk.mhn.de> <20131023120434.GA22316@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:49365 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751054Ab3JWQFX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Oct 2013 12:05:23 -0400
In-Reply-To: <20131023120434.GA22316@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 23. Oktober 2013, 14:04:34 schrieb Steffen Klassert:
> On Wed, Oct 23, 2013 at 01:33:14PM +0200, Wolfgang Walter wrote:
> > Am Mittwoch, 23. Oktober 2013, 10:12:55 schrieb Steffen Klassert:
> > > On Tue, Oct 22, 2013 at 03:46:38PM -0400, David Miller wrote:
> > > > I think we should resolve this soon, even bumping it to 2048 or=
 4096
> > > > and leaving it at that would be I think acceptable.
> > >=20
> > > Yes, of course. Let's use 4096 as the default for ipv4 and ipv6.
> > > I'll take care of it next week.
> >=20
> > I don't know what this value actually means. But on 3.4.x it is muc=
h
> > higher. On a machine with 512MB ram it is 32768, on a machine with =
1GB
> > ram it is 262144 and with 16GB ram it is 4194304.
>=20
> Before  we removed the routing cache, the gc threshold was scaled alo=
ng
> with the maximum routing cache size (ip_rt_max_size). With the routin=
g
> cache removal, we lost the possibility to scale with ip_rt_max_size
> and we had to choose a static default. Maybe we can try to tweak the
> gc threshold again with the available memory somehow later. But to fi=
x
> it now, we need to find a reasonable default value. Would a default o=
f
> 4096 meet your requirements?

Can't say that at the moment. I can test it tonight. I assume that I do=
n't=20
need more than 262144 even on the large router as it worked on older ha=
rdware=20
with less memory (with 3.4.x kernels). No router of us had a value less=
 then=20
32768 with 3.4.x.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
