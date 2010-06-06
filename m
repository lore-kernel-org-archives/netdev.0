From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [2.6.35-rc1] page alloc failure order:1, mode:0x4020
Date: Sun, 06 Jun 2010 12:42:25 +0200
Message-ID: <1275820945.5238.987.camel@edumazet-laptop>
References: <20100604092025.GA96690@trillian.comsick.at>
	 <1275656014.2482.169.camel@edumazet-laptop>
	 <20100604161644.GA98048@trillian.local>
	 <20100606095640.GA4436@trillian.comsick.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Michael Guntsche <mike@it-loops.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100606095640.GA4436@trillian.comsick.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 06 juin 2010 =C3=A0 11:56 +0200, Michael Guntsche a =C3=A9c=
rit :
> On 2010.06.04 18:16:44 , Michael Guntsche wrote:
> > I applied the patch recompiled and run it on the routerboard, tryin=
g
> > to trigger the bug again.
>=20
> Hi Eric,
>=20
> Up to now I was not able to reproduce the bug, do you think this patc=
h
> can be pushed to mainline or is there a "better"/other  fix for it?
>=20
> Kind regards,
> Michael
>=20
>=20

Thanks Michael for testing.

I'll submit ASAP an official patch, sent to all people involved in this
driver to get their Ack (or Nack).

IEEE80211_MAX_MPDU_LEN being 3840 + somebits is suspect, since it doesn=
t
match 802.11 specs.

It should be more close of 2304 + MAC header (32bytes) + FCS (4 bytes) =
?
