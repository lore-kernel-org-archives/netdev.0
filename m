From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] net/mac80211/debugfs: Convert to kstrou8_from_user
Date: Tue, 30 Aug 2011 13:50:55 -0400
Message-ID: <20110830175054.GB2660@tuxdriver.com>
References: <1307478974-32727-1-git-send-email-peterhuewe@gmx.de>
 <201108282152.32180.PeterHuewe@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Peter =?iso-8859-1?Q?H=FCwe?= <PeterHuewe-Mmb7MZpHnFY@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <201108282152.32180.PeterHuewe-Mmb7MZpHnFY@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 28, 2011 at 09:52:31PM +0200, Peter H=FCwe wrote:
> Am Dienstag 07 Juni 2011, 22:36:14 schrieb Peter Huewe:
> > This patch replaces the code for getting an number from a
> > userspace buffer by a simple call to kstrou8_from_user.
> > This makes it easier to read and less error prone.
> >=20
> > Since the old buffer was only 10 bytes long and the value is masked=
 by a
> > nibble-mask anyway, we don't need to use kstrtoul but rather kstrto=
u8.
> >=20
> > Kernel Version: v3.0-rc2
> >=20
> > Signed-off-by: Peter Huewe <peterhuewe-Mmb7MZpHnFY@public.gmane.org>
>=20
> Any updates on this one?
> Still applies to the latest linus' tree

I merged it to wireless-next yesterday.

Thanks for the reminder!

John
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
