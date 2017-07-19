From: Ryan Hsu <ryanhsu@qti.qualcomm.com>
Subject: Re: [PATCH] ath10k_htt_rx_amsdu_allowed(): use ath10k_dbg()
Date: Wed, 19 Jul 2017 18:41:27 +0000
Message-ID: <e41a39fd-87a1-7fc7-158d-cb298e46a754@qca.qualcomm.com>
References: <1500481605.25934.40.camel@perches.com>
 <20170719182454.11267-1-crazy@frugalware.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: Ryan Hsu <ryanhsu@qti.qualcomm.com>,
        "joe@perches.com" <joe@perches.com>,
        Kalle Valo <kvalo@qca.qualcomm.com>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Gabriel Craciunescu <nix.or.die@gmail.com>,
        "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170719182454.11267-1-crazy@frugalware.org>
Content-Language: en-US
Content-ID: <78C732A787223342BC2C05C39710757C@qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/19/2017 11:24 AM, Gabriel Craciunescu wrote:

To make it consistent, maybe rename the patch title starting with ath10k:

> From: Gabriel Craciunescu <nix.or.die@gmail.com>
>
> 	Each time we get disconencted from AP we get flooded with messages like:
>
> 	...
> 	ath10k_pci 0000:03:00.0: no channel configured; ignoring frame(s)!
> 	<until ratelimit kicks in>
> 	ath10k_warn: 155 callbacks suppressed
> 	...
>
> 	Use ath10k_dbg() here too.

You don't need an indentation on every line of the commit.

> Signed-off-by: Gabriel Craciunescu <nix.or.die@gmail.com>
> ---
>  drivers/net/wireless/ath/ath10k/htt_rx.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/ath/ath10k/htt_rx.c b/drivers/net/wirel=
ess/ath/ath10k/htt_rx.c
> index 398dda978d6e..75d9b59b7e63 100644
> --- a/drivers/net/wireless/ath/ath10k/htt_rx.c
> +++ b/drivers/net/wireless/ath/ath10k/htt_rx.c
> @@ -1514,7 +1514,7 @@ static bool ath10k_htt_rx_amsdu_allowed(struct ath1=
0k *ar,
>  	 */
> =20
>  	if (!rx_status->freq) {
> -		ath10k_warn(ar, "no channel configured; ignoring frame(s)!\n");
> +		ath10k_dbg(ar, ATH10K_DBG_HTT, "no channel configured; ignoring frame(=
s)!\n");
>  		return false;
>  	}
> =20

--=20
Ryan Hsu
