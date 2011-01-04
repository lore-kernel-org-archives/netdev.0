From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] ipv4/route.c: respect prefsrc for local routes
Date: Tue, 04 Jan 2011 07:32:09 -0800
Message-ID: <1294155129.6617.37.camel@Joe-Laptop>
References: <1294122260-13245-1-git-send-email-jsing@google.com>
	 <1294125880.2711.34.camel@edumazet-laptop>
	 <1294126407.2711.39.camel@edumazet-laptop>
	 <AANLkTimDms0FTmXWf9WSpcxwZXVVSXQj44jZ2Ag8Osuk@mail.gmail.com>
	 <1294130315.2711.48.camel@edumazet-laptop>
	 <1294150591.3435.0.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>, Joel Sing <jsing@google.com>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2944 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751649Ab1ADPcL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jan 2011 10:32:11 -0500
In-Reply-To: <1294150591.3435.0.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-01-04 at 14:16 +0000, Ben Hutchings wrote:
> On Tue, 2011-01-04 at 09:38 +0100, Eric Dumazet wrote:
> > Le mardi 04 janvier 2011 =C3=A0 16:07 +0800, Changli Gao a =C3=A9cr=
it :
> > > On Tue, Jan 4, 2011 at 3:33 PM, Eric Dumazet <eric.dumazet@gmail.=
com> wrote:
> > > > Le mardi 04 janvier 2011 =C3=A0 08:24 +0100, Eric Dumazet a =C3=
=A9crit :
> > > >> Please use FIB_RES_PREFSRC(res)
> > > > Hmm no, this is not applicable, but this could be shorter :
> > > > fl.fl4_src =3D res.fi->fib_prefsrc ? : fl.fl4_dst;
> > > I think Joe may object the use of "? :"
> > Ternary operator is standard C idiom, used in networking stuff, for
> > example in FIB_RES_PREFSRC() ;)
> However, the option to omit the second operand is a GNU extension.

I don't object to using GNU extensions.

The ?: extension is used in most every major subsystem.

$ grep -rP --include=3D*.[ch] "\?\s*:" * | wc -l
515

(with some false positives)

