From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] Fix kernel lockup in RTL-8169 gigabit ethernet driver
Date: Tue, 6 Apr 2004 09:47:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040406094707.A29666@electric-eye.fr.zoreil.com>
References: <200404060108.19488.Dieter.Nuetzel@hamburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
Content-Transfer-Encoding: quoted-printable
Cc: Linux-Kernel List <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@osd.org>,
        Manfred Spraul <manfred@colorfullife.com>, netdev@oss.sgi.com,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: =?unknown-8bit?Q?Dieter_N=FCtzel?= <Dieter.Nuetzel@hamburg.de>
Content-Disposition: inline
In-Reply-To: <200404060108.19488.Dieter.Nuetzel@hamburg.de>; from Dieter.Nuetzel@hamburg.de on Tue, Apr 06, 2004 at 01:08:19AM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dieter N=FCtzel <Dieter.Nuetzel@hamburg.de> :
[...]
> Isn't the "current" RTL8169s (32/64) driver much outdated?
>=20
> I got a version # 1.6 with all my cards.

This version has been merged in -mm since late 2003. Complete history is
available on the netdev mailing list.

>From memory, there should be a Tx descriptor overflow bug in # 1.6 (see
tx_interrupt). You may want to change some bits in your #1.6 version.

There is a regression related to link removal in the current -mm/jg-netde=
v
version (-mm stands behind jg-netdev where I hope to push what is posted
on the netdev mailing list). Stay tuned. :o)

--
Ueimor
