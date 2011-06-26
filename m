From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.39.2 BUG: unable to handle kernel NULL pointer dereference
Date: Sun, 26 Jun 2011 14:42:27 +0200
Message-ID: <1309092147.2532.33.camel@edumazet-laptop>
References: <BANLkTing9LWO6AjbdzOJzkJ9aoJhn_TLnw@mail.gmail.com>
	 <1309082172.2532.31.camel@edumazet-laptop>
	 <BANLkTikhGVYAFEZGS-AZf3CyS4yVN+Acvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Fabio Coatti <fabio.coatti@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTikhGVYAFEZGS-AZf3CyS4yVN+Acvg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 26 juin 2011 =C3=A0 13:34 +0200, Fabio Coatti a =C3=A9crit =
:
> 2011/6/26 Eric Dumazet <eric.dumazet@gmail.com>:
> > Le dimanche 26 juin 2011 =C3=A0 10:28 +0200, Fabio Coatti a =C3=A9c=
rit :
> >> I'm trying to boot with 2.6.39.2 but the process stops somewhere i=
n
> >> network stack, with a BUG: report.
> >> I've been able to capture the kernel messages usign netconsole, so=
 be
> >> patient with poor alignment :)
>=20
> >
> > Hi Fabio
> >
> > Could you test following patch :
> >
> > http://git2.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git=
;a=3Dcommitdiff;h=3D6407d74c5106bb362b4087693688afd34942b094
> >
> >
> > This should be included in 2.6.39.3, if you confirm this fixes the
> > problem.
> >
>=20
> Yes, I can confirm that your patch fixes the problem, now running
> 2.6.39.2 just fine. Many thanks!

Thanks for testing, David will include this to his stable queue I
presume.
