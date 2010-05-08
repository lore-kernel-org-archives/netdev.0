From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] ipv4: remove ip_rt_secret timer (v4)
Date: Sat, 8 May 2010 08:54:58 -0400
Message-ID: <20100508125458.GA10354@hmsreliant.think-freely.org>
References: <20100506171639.GA5063@hmsreliant.think-freely.org>
 <20100508010108.GA3028@localhost.localdomain>
 <1273300597.2325.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49008 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752426Ab0EHMzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 May 2010 08:55:04 -0400
Content-Disposition: inline
In-Reply-To: <1273300597.2325.55.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 08, 2010 at 08:36:37AM +0200, Eric Dumazet wrote:
> Le vendredi 07 mai 2010 =E0 21:01 -0400, Neil Horman a =E9crit :
> > Hey, Had a moment tonight so I spun version 4 of the patch.
> >=20
> > Change notes:
> > 1) Redid the initialization, in light of Erics clarification.  We r=
andomly seed
> > all 32 bits of the rt_genid for a netns, but still just do 256 byte
> > modifications on cache invalidations
> >=20
> > 2) got rid of the dup checking crap.
> >=20
> >=20
> > Summary:
> >=20
> > A while back there was a discussion regarding the rt_secret_interva=
l timer.
> > Given that we've had the ability to do emergency route cache rebuil=
ds for awhile
> > now, based on a statistical analysis of the various hash chain leng=
ths in the
> > cache, the use of the flush timer is somewhat redundant.  This patc=
h removes the
> > rt_secret_interval sysctl, allowing us to rely solely on the statis=
tical
> > analysis mechanism to determine the need for route cache flushes.
> >=20
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >=20
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Sorry for the confusion Neil, thanks !
Its my fault, it was more clear to me on a second reading.  Apologies!
Neil

>=20
>=20
>=20
