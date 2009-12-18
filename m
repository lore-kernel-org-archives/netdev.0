From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC 1/2] udp: add non-linear uniform port allocation scheme option /proc/sys/net/ipv4/udp_port_randomization
Date: Fri, 18 Dec 2009 15:12:17 +0200
Message-ID: <200912181512.18068.opurdila@ixiacom.com>
References: <4B2933EF.9060606@ixiacom.com> <200912171716.56066.opurdila@ixiacom.com> <4B2A558C.7080204@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:11498 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751165AbZLRNPg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 08:15:36 -0500
In-Reply-To: <4B2A558C.7080204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 17 December 2009 18:00:12 you wrote:
> Le 17/12/2009 16:16, Octavian Purdila a =E9crit :
> > Thanks for reviewing Eric. In this thread
> >
> > http://kerneltrap.org/mailarchive/linux-netdev/2009/5/8/5667204 (po=
rts
> > being reused too fast)
> >
> > Stephen observed that port randomization effects on same port alloc=
ation
> > frequency are explained by the birthday paradox.
>=20
> But this was with TCP, not UDP. Without NAT, UDP has no timewait conc=
ept.
>=20
> > The RFC suggesting port randomization recognizes this issue and sug=
gest a
> > way to overcome it, but on a first glance it looks expensive.
> >
> > Adding a sysctl to sequencial port allocation might not be the best
> > option, but we thought of kicking the discussion about this issue w=
ith
> > this patch.
>=20
> Before sending patches, you might first describe the issue ?
>=20

We really didn't think this through, sorry for the noise. We don't actu=
ally=20
have encountered an issue with UDP, we just extrapolated from the TCP i=
ssue we=20
have seen. So, will come back on this one if we really ran into issues.
