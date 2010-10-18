From: Robin Holt <holt@sgi.com>
Subject: Re: [Patch] Limit sysctl_tcp_mem and sysctl_udp_mem initializers
 to prevent integer overflows.
Date: Mon, 18 Oct 2010 13:34:17 -0500
Message-ID: <20101018183417.GH14064@sgi.com>
References: <20101002112405.951704198@gulag1.americas.sgi.com>
 <20101002112419.248437367@gulag1.americas.sgi.com>
 <20101005.145032.25126909.davem@davemloft.net>
 <20101018174339.GC14068@sgi.com>
 <1287424348.2359.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Robin Holt <holt@sgi.com>, David Miller <davem@davemloft.net>,
	w@1wt.eu, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:53649 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755239Ab0JRSeT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 14:34:19 -0400
Content-Disposition: inline
In-Reply-To: <1287424348.2359.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 18, 2010 at 07:52:28PM +0200, Eric Dumazet wrote:
> Le lundi 18 octobre 2010 =E0 12:43 -0500, Robin Holt a =E9crit :
> > On Tue, Oct 05, 2010 at 02:50:32PM -0700, David Miller wrote:
> > > From: Robin Holt <holt@sgi.com>
> > > Date: Sat, 02 Oct 2010 06:24:06 -0500
> > >=20
> > > > Subject: [Patch] Limit sysctl_tcp_mem and sysctl_udp_mem initia=
lizers to prevent integer overflows.
> > > >=20
> > > > On a 16TB x86_64 machine, sysctl_tcp_mem[2], sysctl_udp_mem[2],=
 and
> > > > sysctl_sctp_mem[2] can integer overflow.  Set limit such that t=
hey are
> > > > maximized without overflowing.
> > > >=20
> > > > Signed-off-by: Robin Holt <holt@sgi.com>
> > >=20
> > > Robin please resubmit this with the SCTP bits included.
> >=20
> > David,
> >=20
> > I did not mean to blow you off.  I was not going to resubmit becaus=
e
> > Eric's patch is the preferred direction.  I had been given an indic=
ation
> > that my patch was preferred, but that indicator changed.
> >=20
>=20
> Maybe there is some misunderstanding.
>=20
> My patch was for net-next kernels (not before 2.6.37), while yours wa=
s
> applicable to previous kernels.

Ah.  I will resubmit then.

Sorry for the confusion,
Robin
