From: Ryan Hsu <ryanhsu@qti.qualcomm.com>
Subject: Re: ath10k_htt_rx_amsdu_allowed() noise
Date: Tue, 18 Jul 2017 07:14:19 +0000
Message-ID: <79f47b0b-eb71-db71-2700-e30b01b11c76@qca.qualcomm.com>
References: <edbe270b-ba70-b844-f814-53d04d07d253@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Gabriel C <nix.or.die@gmail.com>,
        "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <edbe270b-ba70-b844-f814-53d04d07d253@gmail.com>
Content-Language: en-US
Content-ID: <A17343D02A011C42A047C554B42CF5F5@qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/16/2017 03:56 PM, Gabriel C wrote:

>
> Can ath10k_warn() be ath10k_dbg() there ? Maybe this ?
>

Looks good to me.

>
> From d4138d936635ca7b69ed7f7b0cda4914f0f07917 Mon Sep 17 00:00:00 2001
> From: Gabriel Craciunescu <nix.or.die@gmail.com>
> Date: Mon, 17 Jul 2017 00:45:29 +0200
> Subject: [PATCH] ath10k_htt_rx_amsdu_allowed(): change ath10k_warn() to t=
h10k_dbg()
>
> Signed-off-by: Gabriel Craciunescu <nix.or.die@gmail.com>
> ---
>  drivers/net/wireless/ath/ath10k/htt_rx.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/ath/ath10k/htt_rx.c b/drivers/net/wirel=
ess/ath/ath10k/htt_rx.c
> index 398dda978d6e..ad0306cd6ee1 100644
> --- a/drivers/net/wireless/ath/ath10k/htt_rx.c
> +++ b/drivers/net/wireless/ath/ath10k/htt_rx.c
> @@ -1514,7 +1514,7 @@ static bool ath10k_htt_rx_amsdu_allowed(struct ath1=
0k *ar,
>          */
>
>         if (!rx_status->freq) {
> -               ath10k_warn(ar, "no channel configured; ignoriframe(s)!\n=
");
> +               ath10k_dbg(ar, ATH10K_DBG_HTT, "no channel configured, ig=
noring frame(s)!\n");
>                 return false;
>         }
>

Can you send this as patch for reviewing, please?

--=20
Ryan Hsu
