From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH, 2.6.17-rc4-git10] ieee80211softmac_io.c: fix warning "defined but not used"
Date: Fri, 26 May 2006 15:24:37 -0400
Message-ID: <20060526192432.GC32487@tuxdriver.com>
References: <200605231549.43430.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:19211 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751314AbWEZTY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 15:24:56 -0400
To: Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>
Content-Disposition: inline
In-Reply-To: <200605231549.43430.toralf.foerster@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 23, 2006 at 03:49:40PM +0200, Toralf F=F6rster wrote:
> Got this compiler warning today and Johannes Berg <johannes@sipsoluti=
ons.net> wrote:
>=20
> Yeah, known 'bug', we have that code there but never use it. Feel fre=
e
> to submit a patch (to John Linville, CC netdev and softmac-dev) to
> remove it.
>=20
> Signed-off-by: Toralf Foerster <toralf.foerster@gmx.de>

This patch is whitespace-damaged.  Please teach your mailer not to
convert tabs to spaces and resubmit.

Thanks!

John

> --- linux-2.6.17-rc4-git10-pcie-rme9652/net/ieee80211/softmac/ieee802=
11softmac_io.c.old 2006-05-12 09:44:47.000000000 +0200
> +++ linux-2.6.17-rc4-git10-pcie-rme9652/net/ieee80211/softmac/ieee802=
11softmac_io.c     2006-05-23 15:16:38.000000000 +0200
> @@ -456,31 +456,3 @@
>         return IEEE80211_2ADDR_LEN;
>  }
>=20
> -
> -/* Sends a control packet */
> -static int
> -ieee80211softmac_send_ctl_frame(struct ieee80211softmac_device *mac,
> -       struct ieee80211softmac_network *net, u32 type, u32 arg)
> -{
> -       void *pkt =3D NULL;
> -       u32 pkt_size =3D 0;

<snip>

--=20
John W. Linville
linville@tuxdriver.com
