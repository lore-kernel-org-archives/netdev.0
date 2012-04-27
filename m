From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Fri, 27 Apr 2012 12:17:32 +0200
Message-ID: <20120427101732.GX3157@wantstofly.org>
References: <1335517711-6522-1-git-send-email-sedat.dilek@gmail.com>
 <20120427091405.GS3157@wantstofly.org>
 <CA+icZUVAK3NHmbG5kR1KhqGe9mAimWWzLz-MfXOXbyry3Sz73w@mail.gmail.com>
 <20120427094007.GU3157@wantstofly.org>
 <CA+icZUUiYwpHpqe5_kz1rLzTT13qQMwpNpDH7EOaRrVi_c8Z2Q@mail.gmail.com>
 <20120427094637.GV3157@wantstofly.org>
 <CA+icZUXNZ=exTnR=OgD_9bpt_0s-KnR+v-K6u+XzQr4HBoTQHQ@mail.gmail.com>
 <20120427095842.GW3157@wantstofly.org>
 <CA+icZUWuynSaPE4pdxzoP783pw7r=5x27ewXN_pkR5VS=0kKUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sedat.dilek@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+icZUWuynSaPE4pdxzoP783pw7r=5x27ewXN_pkR5VS=0kKUg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 27, 2012 at 12:12:13PM +0200, Sedat Dilek wrote:

> >> >> >> Are you planning to or even working on support (for) 8361 de=
vices?
> >> >> >
> >> >> > I don't have any such plans, and I don't know of anyone who d=
oes.
> >> >>
> >> >> Does 8361 require firmware support?
> >> >
> >> > What do you mean by that?
> >>
> >> IIRC ath5k for example needs no external firmware file.
> >
> > The 8361 requires firmware to be loaded into it before it'll do
> > anything useful.
> >
> >
> >> >> Does a firmware file exist (name?)?
> >> >
> >> > There's firmware for the 8361 out there, however, that version o=
f
> >> > the firmware implements a firmware API that is different from th=
e
> >> > one that mwl8k currently implements.
> >> >
> >> > You could add 8361 support to mwl8k, but then you'd have to go o=
ver
> >> > all the firmware command invocations in mwl8k and make sure that=
 they
> >> > will work on the 8361 firmware that you're trying to support as =
well.
> >>
> >> Without having a 8361 this will be even harder to walk through.
> >>
> >> Anyway, thanks for your detailed explanations.
> >>
> >> What's the alternative for such affected users?
> >> Use ndis-wrapper?
> >
> > I'm not sure. =A0I've never tried to get a 8361 work under Linux.
>=20
> Just found on [1] this same wrong patch in [2] :-).
> Dunno if [3] worked and from where they have stolen fw-files.
>=20
> - Sedat -
>=20
> [1] https://dev.openwrt.org/ticket/7209
> [2] https://dev.openwrt.org/attachment/ticket/7209/mwl8k_fix_pci_id.p=
atch
> [3] https://dev.openwrt.org/attachment/ticket/7209/mwl8k_8361p.patch

I doubt that [3] is really all that's needed to make it work.  But if
there's someone for whom it works, I'd like them to run some tests on
mwl8k + [3] on 88w8361p.
