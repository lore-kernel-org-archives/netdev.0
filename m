From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [3.8-rc] regression: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Thu, 7 Feb 2013 01:46:35 +0100
Message-ID: <20130207004635.GA4025@electric-eye.fr.zoreil.com>
References: <CADDKRnBqxSwC7HUP_aN1QELrv2+7jnncXj7EP0Pqv8E8FFTpPw@mail.gmail.com> <20130105093718.GA938@electric-eye.fr.zoreil.com> <CADDKRnBCrDz2X=5qpGE+r92ZFX5cA+jnSGt3wS8TR0RE8hi1HA@mail.gmail.com> <20130105165735.GB4906@electric-eye.fr.zoreil.com> <CADDKRnCkDS5rMSSi12ti5PV_RSP6s3S15YOJz8b98ehcsyKaOA@mail.gmail.com> <CADDKRnACHgBOmw0qLE4zVzhq=Yw-1AYJ-JW0muxRCR3jZ=VoUQ@mail.gmail.com> <CADDKRnAHJAZBittLCFxjgWa1AWKxD7a4hn4v=xvax=ergkKjxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: =?utf-8?B?SsO2cmc=?= Otte <jrg.otte@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CADDKRnAHJAZBittLCFxjgWa1AWKxD7a4hn4v=xvax=ergkKjxA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

J=C3=B6rg Otte <jrg.otte@gmail.com> :
[...]
> To Summarize: Two net-regressions where introduced in v3.8 (driver r8=
169):
>=20
> 1) NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
> was introduced by commit
> e0c075577965d1c01b30038d38bf637b027a1df3
> ("r8169: enable ALDPS for power saving")

Hayes Wang <hayeswang@realtek.com> authored it. You should ask him
why commit e0c075577965d1c01b30038d38bf637b027a1df3 sometimes chokes
with the 8168evl.=20

And you can ask him if there is a chance that the non-8168evl that are
handled by the patch (mis-)behave the same too.

--=20
Ueimor
