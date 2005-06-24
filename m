From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [git patch] urgent e1000 fix
Date: Fri, 24 Jun 2005 09:40:09 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0506240938210.11175@ppc970.osdl.org>
References: <13661.1119601379@kao2.melbourne.sgi.com>
 <Pine.LNX.4.58.0506240149440.11175@ppc970.osdl.org>
 <Pine.BSO.4.62.0506241140280.19853@rudy.mif.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Keith Owens <kaos@ocs.com.au>, Denis Vlasenko <vda@ilport.com.ua>,
	Jeff Garzik <jgarzik@pobox.com>,
	David Lang <david.lang@digitalinsight.com>,
	Andrew Morton <akpm@osdl.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S263126AbVFXQiq@vger.kernel.org>
To: =?ISO-8859-1?Q?Tomasz_K=B3oczko?= <kloczek@rudy.mif.pg.gda.pl>
In-Reply-To: <Pine.BSO.4.62.0506241140280.19853@rudy.mif.pg.gda.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 24 Jun 2005, Tomasz K=B3oczko wrote:
>=20
> Linus .. why for kernel tree can't be used indent or other source=20
> code formater ?

Sure, we do it, but then we try to make it obvious to all sides.

It's the "small and non-obvious" differences that are really poisonous.=
=20
You don't see them in the soruces, yet patches don't apply.

So don't do subtle whitespace "fixups" by default. It just makes everyb=
ody
unhappy down the line.

That's not to say that we don't do whitespace fixups _occasionally_. Wh=
en=20
it's ugly enough to be noticeable, I sure as hell fix up whitespace. Bu=
t=20
not by default.

		Linus
