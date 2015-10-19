From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH v2 2/3] net: wireless: b43: Coding Style
Date: Mon, 19 Oct 2015 18:07:42 +0200
Message-ID: <20151019180742.2d6bf8f1@wiggum>
References: <1445270543-2209-1-git-send-email-paulmcquad@gmail.com>
	<1445270543-2209-3-git-send-email-paulmcquad@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/kjQNXG5xSoHxyO4rq.PYUrx"; protocol="application/pgp-signature"
Cc: zajec5@gmail.com, davem@davemloft.net, joe@perches.com,
	johannes.berg@intel.com, sd@queasysnail.net,
	mike.looijmans@topic.nl, khoroshilov@ispras.ru, cengelma@gmx.at,
	linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Paul McQuade <paulmcquad@gmail.com>, kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445270543-2209-3-git-send-email-paulmcquad@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/kjQNXG5xSoHxyO4rq.PYUrx
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 19 Oct 2015 17:02:22 +0100
Paul McQuade <paulmcquad@gmail.com> wrote:

> Fixed Pointer Coding Style
>=20
> Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
> ---
>  drivers/net/wireless/b43/main.c | 6 +++---
>  drivers/net/wireless/b43/main.h | 2 +-
>  drivers/net/wireless/b43/xmit.h | 2 +-
>  3 files changed, 5 insertions(+), 5 deletions(-)
>=20
> diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/m=
ain.c
> index 2849070..040caa4 100644
> --- a/drivers/net/wireless/b43/main.c
> +++ b/drivers/net/wireless/b43/main.c
> @@ -364,7 +364,7 @@ static struct ieee80211_supported_band b43_band_2ghz_=
limited =3D {
> =20
>  static void b43_wireless_core_exit(struct b43_wldev *dev);
>  static int b43_wireless_core_init(struct b43_wldev *dev);
> -static struct b43_wldev * b43_wireless_core_stop(struct b43_wldev *dev);
> +static struct b43_wldev *b43_wireless_core_stop(struct b43_wldev *dev);
>  static int b43_wireless_core_start(struct b43_wldev *dev);
>  static void b43_op_bss_info_changed(struct ieee80211_hw *hw,
>  				    struct ieee80211_vif *vif,
> @@ -989,7 +989,7 @@ static void do_key_write(struct b43_wldev *dev,
>  		 * 0xffffffff and let's b43_op_update_tkip_key provide a
>  		 * correct pair.
>  		 */
> -		rx_tkip_phase1_write(dev, index, 0xffffffff, (u16*)buf);
> +		rx_tkip_phase1_write(dev, index, 0xffffffff, (u16 *)buf);
>  	} else if (index >=3D pairwise_keys_start) /* clear it */
>  		rx_tkip_phase1_write(dev, index, 0, NULL);
>  	if (key)
> @@ -4334,7 +4334,7 @@ out_unlock:
>  /* Locking: wl->mutex
>   * Returns the current dev. This might be different from the passed in d=
ev,
>   * because the core might be gone away while we unlocked the mutex. */
> -static struct b43_wldev * b43_wireless_core_stop(struct b43_wldev *dev)
> +static struct b43_wldev *b43_wireless_core_stop(struct b43_wldev *dev)
>  {
>  	struct b43_wl *wl;
>  	struct b43_wldev *orig_dev;
> diff --git a/drivers/net/wireless/b43/main.h b/drivers/net/wireless/b43/m=
ain.h
> index c46430c..fa56b22 100644
> --- a/drivers/net/wireless/b43/main.h
> +++ b/drivers/net/wireless/b43/main.h
> @@ -73,7 +73,7 @@ static inline int b43_is_ofdm_rate(int rate)
>  u8 b43_ieee80211_antenna_sanitize(struct b43_wldev *dev,
>  				  u8 antenna_nr);
> =20
> -void b43_tsf_read(struct b43_wldev *dev, u64 * tsf);
> +void b43_tsf_read(struct b43_wldev *dev, u64 *tsf);
>  void b43_tsf_write(struct b43_wldev *dev, u64 tsf);
> =20
>  u32 b43_shm_read32(struct b43_wldev *dev, u16 routing, u16 offset);
> diff --git a/drivers/net/wireless/b43/xmit.h b/drivers/net/wireless/b43/x=
mit.h
> index ba61153..fed8657 100644
> --- a/drivers/net/wireless/b43/xmit.h
> +++ b/drivers/net/wireless/b43/xmit.h
> @@ -203,7 +203,7 @@ size_t b43_txhdr_size(struct b43_wldev *dev)
> =20
> =20
>  int b43_generate_txhdr(struct b43_wldev *dev,
> -		       u8 * txhdr,
> +		       u8 *txhdr,
>  		       struct sk_buff *skb_frag,
>  		       struct ieee80211_tx_info *txctl, u16 cookie);
> =20


Acked-by: Michael Buesch <m@bues.ch>


--=20
Michael

--Sig_/kjQNXG5xSoHxyO4rq.PYUrx
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWJRVPAAoJEPUyvh2QjYsOGoUQAKtCKx4keJ6Gfc3gNEFy0w2E
STD1+s5SiCvyP1jNNtAbZbP3y6bcGpYQ44luLtK7wFsfBYOOSFVaHYhYe0qRTdrr
kJAFA0HUpLTYhEef3/d5OmpUIQcZ1kZrOv1L2zmnaQTo6hfn0Cl2nISekUL2CpvY
nn+mhyHV5xgC61auQmd/kzhAZcSWeUeAqNmzrbE1d3nmhpuVd6pZFGssGZr7MlqT
YC0LdzmUJcLdB7GpR95zVnzhl7whc8es280763M/TG7MF8reGYThhjloNJOOGQ4W
G7/CO/UiEaMzj9sLoRc+t+05+9daEfBRUiWY74Clg6/xrznQkWh90RzCRL79G2Df
mFtR0FGaN/EcN8RZgFSsomFCCXKhi6pvhbVJJpF5lra4KU2EzY+DO5agVZnnMVSr
Rjg8RwY+ZnSPc8ZOGtraGtUDVQCkG7fiUZQvotI11Sk0vvu7xiNCtFnyUTH8rQQ/
qB8utiFKl7Aay1C+CnKkID7TsUIx/QHKDJA4YrDH8jAcPaCHTvscEgOXelwKlkXx
YCX8OLjAGexkRzWcUyLUcCEO7hEbuSAQPKz1jLC6KFT3h9WdumHg7CUDdr7NWL6w
iyUFcOh+Vqt916u7z/AiqmVmEB8OhckURsYMe+dbfasYTbb7zLbankqpyo59DClf
Gvxb7UG/9pvEzbA+0lLc
=8w12
-----END PGP SIGNATURE-----

--Sig_/kjQNXG5xSoHxyO4rq.PYUrx--
