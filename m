From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: Re: [PATCH 1 of 5] IPv6: do not wrap around when the lifetime has
	expired
Date: Thu, 27 Mar 2008 20:38:54 +0100
Message-ID: <20080327193854.GC8574@ens-lyon.fr>
References: <patchbomb.1206305168@pirzuine> <dd125a7f86968371046d.1206305169@pirzuine> <20080328.032539.66693379.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, pekkas@netcore.fi
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pilet.ens-lyon.fr ([140.77.167.16]:44155 "EHLO
	pilet.ens-lyon.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757222AbYC0Ti6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 15:38:58 -0400
Content-Disposition: inline
In-Reply-To: <20080328.032539.66693379.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 03:25:39AM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <dd125a7f86968371046d.1206305169@pirzuine> (at Sun, 23 Mar=
 2008 21:46:09 +0100), Benoit Boissinot <benoit.boissinot@ens-lyon.org>=
 says:
>=20
> > IPv6: do not wrap around when the lifetime has expired
> >=20
> > Instead of reporting overly large lifetimes to userspace,
> > report a lifetime of 0 when a lifetime has expired.
> >=20
> > Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
>=20
> NAK.
>=20
> (signed) lifetime < 0 means it has expired, but 0 does not mean
> that the lifetime has expired, but it is being expired
> (within 1 second).

It makes sense, so is the output of ip addr correct ?

inet6 2a01:5d8:58a0:ebfc:b5fb:88a3:27a5:ce96/64 scope global secondary =
deprecated dynamic
   valid_lft 84064sec preferred_lft 4294964960sec

Can iproute2 be "fixed" ? or is it the expected output ?

thanks,

Benoit

--=20
:wq
