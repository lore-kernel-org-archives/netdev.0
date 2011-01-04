From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ipv4/route.c: respect prefsrc for local routes
Date: Tue, 04 Jan 2011 14:16:31 +0000
Message-ID: <1294150591.3435.0.camel@bwh-desktop>
References: <1294122260-13245-1-git-send-email-jsing@google.com>
	 <1294125880.2711.34.camel@edumazet-laptop>
	 <1294126407.2711.39.camel@edumazet-laptop>
	 <AANLkTimDms0FTmXWf9WSpcxwZXVVSXQj44jZ2Ag8Osuk@mail.gmail.com>
	 <1294130315.2711.48.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Joe Perches <joe@perches.com>,
	Joel Sing <jsing@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:57601 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947Ab1ADOQe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 09:16:34 -0500
In-Reply-To: <1294130315.2711.48.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-01-04 at 09:38 +0100, Eric Dumazet wrote:
> Le mardi 04 janvier 2011 =C3=A0 16:07 +0800, Changli Gao a =C3=A9crit=
 :
> > On Tue, Jan 4, 2011 at 3:33 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> > > Le mardi 04 janvier 2011 =C3=A0 08:24 +0100, Eric Dumazet a =C3=A9=
crit :
> > >
> > >> Please use FIB_RES_PREFSRC(res)
> > >>
> > >
> > > Hmm no, this is not applicable, but this could be shorter :
> > >
> > > fl.fl4_src =3D res.fi->fib_prefsrc ? : fl.fl4_dst;
> > >
> > >
> >=20
> > I think Joe may object the use of "? :"
> >=20
>=20
> Ternary operator is standard C idiom, used in networking stuff, for
> example in FIB_RES_PREFSRC() ;)
[...]

However, the option to omit the second operand is a GNU extension.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

