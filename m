From: Ingo Molnar <mingo@elte.hu>
Subject: Re: BUG in 2.6.29 final: broken network connection
Date: Tue, 24 Mar 2009 20:42:54 +0100
Message-ID: <20090324194254.GB26930@elte.hu>
References: <200903241812.14577.sinter.salt@gmx.de> <20090324172503.1627a3ef@lxorguk.ukuu.org.uk> <200903241918.29929.sinter.salt@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: sinter <sinter.salt@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:44392 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762268AbZCXTnO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2009 15:43:14 -0400
Content-Disposition: inline
In-Reply-To: <200903241918.29929.sinter.salt@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* sinter <sinter.salt@gmx.de> wrote:

> Am Dienstag 24 M=E4rz 2009 18:25:03 schrieben Sie:
> > > It cost me almost 1 complete day
> >
> > Wouldn't it have been simpler to wait when you found a problem and =
read
> > Ingo's email on the subject from a few hours ago ?
>=20
> Wouldn't it be simpler to restrictively avoid crap code in final=20
> kernel versions? And if that does not work by appeal shouldn't the=20
> netdev maintainer simply be substituted?
>=20
> Who needs a maintainer adding his SOB with closed eyes under=20
> untested crap code? Who needs someone like that for kernel=20
> development?

Nonsense. 303c6a0 "gro: Fix legacy path napi_complete crash" was an=20
obvious looking bug fix for a real crash that was reported, against=20
a commit that went upstream in 2.6.29-rc1.

It was a fix for a serious regression and i'd have applied it too,=20
and would have pushed it to Linus.

=46urthermore, even on affected systems it took certain configs and=20
certain conditions for the bug to trigger under high load. So there=20
was no real good way to find this bug quickly.

Such kind of bugs can happen anytime, to any maintainer. Unless we=20
100% freeze the kernel for a full month before release, this risk=20
simply cannot be avoided. It is far more problematic if maintainers=20
dont push known fixes or ignore fixes. The networking tree is=20
exemplary in picking up fixes addressing bug reports quickly. A=20
proposed fix was posted 33 minutes after i sent my bugreport.

Things breaking is simply the nature of software changes - get used=20
to it. When new software with 1 million lines of changes over the=20
previous version comes out, dont jump on it immediately, if your=20
peace of mind depends on a 100% working system. Only try it if you=20
want to help out developing it.

And there's an easy solution for you in any case: you can wait for=20
=2E29.1 which i'm sure will be out quickly.

Thanks,

	Ingo
