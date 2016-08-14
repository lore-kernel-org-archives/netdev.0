From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2 (linux-stable-4.5.y)] Revert "stmmac:
 Fix 'eth0: No PHY found' regression"
Date: Sun, 14 Aug 2016 17:44:34 +0200
Message-ID: <20160814154434.GI20560@kroah.com>
References: <1464009463-23654-1-git-send-email-peppe.cavallaro@st.com>
 <1464009463-23654-2-git-send-email-peppe.cavallaro@st.com>
Reply-To: greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, robin.murphy-5wv7dgnIgG8@public.gmane.org, marc.zyngier-5wv7dgnIgG8@public.gmane.org,
	afaerber-l3A5Bk7waGM@public.gmane.org, bert-phGP8mJ4Mqk@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	Gabriel Fernandez <gabriel.fernandez-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Frank =?iso-8859-1?Q?Sch=E4fer?= <fschaefer.oss-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	Dinh Nguyen <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Return-path: <linux-sunxi+bncBDK73744WQBRBV5DYK6QKGQEW4CDP5I-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <1464009463-23654-2-git-send-email-peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Mon, May 23, 2016 at 03:17:42PM +0200, Giuseppe Cavallaro wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
>=20
> This reverts commit 88f8b1bb41c6208f81b6a480244533ded7b59493.
> due to problems on GeekBox and Banana Pi M1 board when
> connected to a real transceiver instead of a switch via
> fixed-link.
>=20
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
> Cc: Gabriel Fernandez <gabriel.fernandez-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> Cc: Andreas F=C3=A4rber <afaerber-l3A5Bk7waGM@public.gmane.org>
> Cc: Frank Sch=C3=A4fer <fschaefer.oss-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
> Cc: Dinh Nguyen <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c     | 11 ++++++++++-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |  9 +--------
>  2 files changed, 11 insertions(+), 9 deletions(-)

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
