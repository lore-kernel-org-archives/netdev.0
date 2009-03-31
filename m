From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/9] RDS: Fix ordering in a conditional
Date: Tue, 31 Mar 2009 14:50:13 -0700 (PDT)
Message-ID: <20090331.145013.206671022.davem@davemloft.net>
References: <1238438693-29540-7-git-send-email-andy.grover@oracle.com>
	<adak566e2pi.fsf@cisco.com>
	<c0a09e5c0903302356m688fd370k65151f99f43dfdfc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rdreier@cisco.com, andy.grover@oracle.com, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com
To: andy.grover@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39900
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756698AbZCaVuY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2009 17:50:24 -0400
In-Reply-To: <c0a09e5c0903302356m688fd370k65151f99f43dfdfc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Andrew Grover <andy.grover@gmail.com>
Date: Mon, 30 Mar 2009 23:56:14 -0700

> On Mon, Mar 30, 2009 at 9:27 PM, Roland Dreier <rdreier@cisco.com> wr=
ote:
> > =A0> - =A0 =A0if (0 <=3D ret && (unsigned) ret < nr_pages) {
> > =A0> + =A0 =A0if (ret > 0 && (unsigned) ret < nr_pages) {
> >
> > This is not an equivalent transformation -- the original code is tr=
ue if
> > ret =3D=3D 0, while the new code is false.
>=20
> Ah! Good point.
>=20
> > Also it seems you don't need the unsigned cast here, since the clau=
se
> > before just checked that ret is positive?
>=20
> True, but I'd bet the compiler will warn if we remove it. I'll try it
> tomorrow and see.

Andy, also please resubmit only the real honest-to-goodness bug fixes
in this patch series.

I don't want to see cleanups, or optimizations like the transformation
over to using get_user_pages_fast().

You could have sent that kind of stuff to me weeks ago.

Thanks.

