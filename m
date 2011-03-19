From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: No networking since git3
Date: Sat, 19 Mar 2011 16:18:50 +0100
Message-ID: <1300547930.2831.27.camel@edumazet-laptop>
References: <4D84A46B.1000407@example.com>
	 <AANLkTi=qrK2L+MA5F5fQ6S76LLPXkYhyLg7JL4_vrkRe@mail.gmail.com>
	 <4D84A9F6.8080402@example.com>
	 <AANLkTimFGeHYEOxx=h883rRJL463g1CBUDS0wGM-52Nj@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: piotr@hosowicz.com, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>,
	Oliver Neukum <oneukum@suse.de>
To: Anca Emanuel <anca.emanuel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimFGeHYEOxx=h883rRJL463g1CBUDS0wGM-52Nj@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 19 mars 2011 =C3=A0 16:08 +0200, Anca Emanuel a =C3=A9crit :
> 2011/3/19 Piotr Hosowicz <piotr@hosowicz.com>:
> > On 19.03.2011 13:56, Anca Emanuel wrote:
> >>
> >> 2011/3/19 Piotr Hosowicz<piotr@hosowicz.com>:
> >>>
> >>> Hello,
> >>>
> >>> I wrote lately, the problem persists, that's why I write again. I=
 tested
> >>> git7 just now and it still does not work.
> >>
> >> Same problem here:
> >>
> >> [   12.923685] r8169 0000:04:00.0: eth0: link down
> >> [   12.923941] ADDRCONF(NETDEV_UP): eth0: link is not ready
> >>
> >> dmesg attached.
> >
> > Nice to hear that I am not the only person with this problem. I for=
got about
> > the dmesg.
> >
> > Regards,
> >
> > Piotr Hosowicz
>=20
> Added CCs

Hi

Problem comes from commit 54405cde762408b00a445466a40da4f7f33a8479
(r8169: support control of advertising.)

Reverting it brings back NIC for me
