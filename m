From: =?utf-8?B?Ss61YW4=?= Sacren <sakiwit@gmail.com>
Subject: Re: [PATCH net-next] sock: fix comment location
Date: Sun, 3 May 2015 15:11:58 -0600
Message-ID: <20150503211158.GA16515@mail.gmail.com>
References: <1430686519-20548-1-git-send-email-sakiwit@gmail.com>
 <20150503210534.GG22481@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:35612 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbbECVPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 17:15:52 -0400
Received: by obcux3 with SMTP id ux3so94860325obc.2
        for <netdev@vger.kernel.org>; Sun, 03 May 2015 14:15:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150503210534.GG22481@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Westphal <fw@strlen.de>
Date: Sun, 03 May 2015 23:05:34 +0200
>
> J=CE=B5an Sacren <sakiwit@gmail.com> wrote:
> > From: Jean Sacren <sakiwit@gmail.com>
> >=20
> > The block of comment is for 'sk_incoming_cpu' rather than 'sk_txhas=
h'.
> > Therefore, move it above "u16 sk_incoming_cpu;" where it belongs.
>=20
> comment is at the right place.
>=20
> > diff --git a/include/net/sock.h b/include/net/sock.h
> > --- a/include/net/sock.h
> > +++ b/include/net/sock.h
> > -	u16			sk_incoming_cpu;
> >  	/* 16bit hole
> >  	 * Warned : sk_incoming_cpu can be set from softirq,
> >  	 * Do not use this hole without fully understanding possible issu=
es.
> >  	 */
> > +	u16			sk_incoming_cpu;
>=20
> This hole is between sk_incoming_cpu and sk_txhash.

I'm so sorry. Thank you for teaching me. I did wish there were an empty
line below "u16 sk_incoming_cpu;"
