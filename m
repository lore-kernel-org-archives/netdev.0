From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2 add hoplimit parsing and update usage and
 documentation
Date: Tue, 6 Oct 2009 10:34:22 -0700
Message-ID: <20091006103422.010e4ade@nehalam>
References: <1254836434.544524.27946.nullmailer@watson.codefidence.com>
	<4ACB7AF4.4070207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gilad Ben-Yossef <gilad@codefidence.com>, netdev@vger.kernel.org,
	Ori Finkelman <ori@comsleep.com>,
	Andreas Henriksson <andreas@fatal.se>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39576 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932247AbZJFRfF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 13:35:05 -0400
In-Reply-To: <4ACB7AF4.4070207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 06 Oct 2009 19:14:28 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Gilad Ben-Yossef a =C3=A9crit :
> > From: Gilad Ben-Yossef <gilad@codefidence.com>
> >=20
> > - Parse and handle the hoplimit ip route option and add it to the u=
sage=20
> >   line and documentation.
> >=20
> > - Add the missing reordering ip route option to the usage line.
> >=20
> > - Add documentation for initcwnd ip route option.
> >=20
> > Tested by setting hoplimit and retreiving it via "show".=20
> >=20
> > Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
> > [ported to HEAD, fixed a bug with hoplimit lock handling, added doc=
umentation]
> > Signed-off-by: Ori Finkelman <ori@comsleep.com>
> > Signed-off-by: Yony Amit <yony@comsleep.com>
> >=20
>=20
> > --- a/ip/iproute.c
> > +++ b/ip/iproute.c
> > @@ -13,6 +13,8 @@
> >   *
> >   * Rani Assaf <rani@magic.metawire.com> 980929:	resolve addresses
> >   * Kunihiro Ishiguro <kunihiro@zebra.org> 001102: rtnh_ifindex was=
 not initialized
> > + * Gilad Ben-Yossef <gilad@codefidence.com> 091006: Add hoplimit o=
ption parsing=20
> > + * and correct usage
>=20
> Well, git/web history is much better than this, you dont need to add =
this comment.
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> patch should be sent to iproute2 maintainer, Stephen Hemminger <shemm=
inger@vyatta.com>
>=20
> He might be too busy to catch netdev mails these days, I dont know :)
>=20
> Thanks

I catch them, but collect iproute patches and put them in batches aroun=
d
release time.

--=20
