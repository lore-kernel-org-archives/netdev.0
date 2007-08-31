From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: Please pull 'upstream-jgarzik' branch of wireless-2.6
Date: Fri, 31 Aug 2007 09:44:49 -0400
Message-ID: <46D81B51.4060102@garzik.org>
References: <20070828231731.GB2967@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070828231731.GB2967-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> Jeff,
>=20
> A few more for 2.6.24 -- mostly libertas.
>=20
> Individual patches are available here:
>=20
> 	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/=
upstream-jgarzik/
>=20
> Thanks!
>=20
> John
>=20
> ---
>=20
> The following changes since commit e54cfa621f4cca9cca500019aa600c71d2=
0f0592:
>   Jeff Garzik (1):
>         Merge branch 'upstream-jgarzik' of git://git.kernel.org/.../l=
inville/wireless-2.6 into upstream
>=20
> are available in the git repository at:
>=20
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6=
=2Egit upstream-jgarzik
>=20
> Andrew Morton (1):
>       libertas: printk warning fixes
>=20
> Brajesh Dave (1):
>       libertas: advertise 11g ad-hoc rates
>=20
> Dan Williams (4):
>       libertas: fix inadvertant removal of bits from commit 831441862=
956fffa17b9801db37e6ea1650b0f69
>       libertas: reorganize and simplify init sequence
>       libertas: don't stomp on interface-specific private data
>       libertas: send reset command directly instead of calling libert=
as_reset_device
>=20
> Jesper Juhl (1):
>       net: Kill some unneeded allocation return value casts in libert=
as
>=20
> Johannes Berg (1):
>       rtl8187: remove IEEE80211_HW_DATA_NULLFUNC_ACK
>=20
> John W. Linville (1):
>       libertas: remove unused adhoc_rates_b definition
>=20
> Marek Va=C5=A1ut (1):
>       libertas: region code values specified as 8bit
>=20
> Pierre Ossman (1):
>       libertas: properly end commands on hardware failure
>=20
>  drivers/net/wireless/libertas/cmd.c     |    2 +
>  drivers/net/wireless/libertas/cmdresp.c |    6 +-
>  drivers/net/wireless/libertas/debugfs.c |    2 +-
>  drivers/net/wireless/libertas/decl.h    |    3 +-
>  drivers/net/wireless/libertas/dev.h     |    4 -
>  drivers/net/wireless/libertas/ethtool.c |    3 +-
>  drivers/net/wireless/libertas/if_cs.c   |   58 +----
>  drivers/net/wireless/libertas/if_usb.c  |  371 +++++++++++++--------=
--------
>  drivers/net/wireless/libertas/if_usb.h  |    4 +-
>  drivers/net/wireless/libertas/join.c    |    7 +-
>  drivers/net/wireless/libertas/main.c    |  408 +++++++++++++--------=
----------
>  drivers/net/wireless/rtl8187_dev.c      |    3 +-
>  12 files changed, 354 insertions(+), 517 deletions(-)

pulled
