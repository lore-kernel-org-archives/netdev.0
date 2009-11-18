From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [RFC v2] mac80211: disallow bridging managed/adhoc interfaces
Date: Tue, 17 Nov 2009 21:59:20 -0500
Message-ID: <20091118025920.GA4588@tuxdriver.com>
References: <1258465585.3682.7.camel@johannes.local> <1258490898.21197.42.camel@johannes.local> <jwvy6m4bnqp.fsf-monnier+gmane.linux.kernel.wireless.general@gnu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stefan Monnier <monnier-CRDzTM1onBSWkKpYnGOUKg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <jwvy6m4bnqp.fsf-monnier+gmane.linux.kernel.wireless.general-mXXj517/zsQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 17, 2009 at 08:59:03PM -0500, Stefan Monnier wrote:
> > A number of people have tried to add a wireless interface
> > (in managed mode) to a bridge and then complained that it
> > doesn't work. It cannot work, however, because in 802.11
> [...]
> > To avoid such mistakes in the future, disallow adding a
> > wireless interface to a bridge.
>=20
> As someone who's been bitten by this, I fully support this change.
> Still, it makes me wonder: my broadcom-based home-router using the wl=
=2Eo
> driver can be set in "client bridge" mode.  How does it work?

If I'm not mistaken, that has a bunch of code embedded in it that
among other things can do a layer-2 version of NAT to rewrite the
MAC adresses for frames on the air.

YMMV...

John
--=20
John W. Linville =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Someday the world will =
need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0might be all =
we have. =A0Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
