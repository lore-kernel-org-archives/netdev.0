From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Subject: Re: [PATCH] [NETDEV] [000]  dmfe : fix bugs and add features
Date: Sat, 10 Feb 2007 16:22:26 +0100
Message-ID: <20070210152226.GA3482@interface.famille.thibault.fr>
References: <96797.60132.qm@web38511.mail.mud.yahoo.com> <45CCE46E.9010902@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Levitsky Maxim <maximlevitsky@yahoo.com>,
	linux-kernel@vger.kernel.org, tori@unhappy.mine.nu,
	netdev@vger.kernel.org, sebastien.hinderer@loria.fr
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932590AbXBJPWd@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <45CCE46E.9010902@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Jeff Garzik, le Fri 09 Feb 2007 16:15:26 -0500, a =E9crit :
> Levitsky Maxim wrote:
> >Before some time I decided to fix suspend/resume on my Davicom
> >network card.  During development I also fixed couple of bugs and
> >added support for link detection and WOL Note : 2.6.20 already has
> >support for link detection , but it is broken when card has external
> >PHY, like mine.
> >
> >So here it goes:
> >
> >[PATCH] [NET] [001] dmfe : trivial/spelling fixes
> >[PATCH] [NET] [002] dmfe : Fix possible oops
> >[PATCH] [NET] [003] dmfe : fix link detection
> >[PATCH] [NET] [004] dmfe : Add suspend/resume support
> >[PATCH] [NET] [005] dmfe : Add support for wake-on-lan
>=20
> >Commit 7628b0a8c01a02966d2228bdf741ddedb128e8f8 (drivers/net/tulip/d=
mfe:=20
> >support basic carrier detection) breaks networking on my Davicom DM9=
009.=20
> >ethtool always reports there is no link.  tcpdump shows incoming=20
> >packets, but TX is disabled.  Reverting the above patch fixes the=20
> >problem.
>=20
> What about the above report?
>=20
> I would rather fix this first, before applying more patches on top of=
 a=20
> problematic patch...

My patch wasn't implementing anything actually: it was just making the
existing-since-long link detection code available in ethtools.

Samuel
