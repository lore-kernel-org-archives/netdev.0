From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] ath10k_htt_rx_amsdu_allowed(): use ath10k_dbg()
Date: Wed, 19 Jul 2017 09:26:45 -0700
Message-ID: <1500481605.25934.40.camel@perches.com>
References: <288fce5b-d738-f0ac-2433-67e1b35a0664@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ryan Hsu <ryanhsu@qti.qualcomm.com>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Kalle Valo <kvalo@qca.qualcomm.com>
To: Gabriel C <nix.or.die@gmail.com>,
        "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <288fce5b-d738-f0ac-2433-67e1b35a0664@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-07-19 at 17:37 +0200, Gabriel C wrote:
>          Each time we get disconencted from AP we get flooded with messages like:
> 
>          ...
>          ath10k_pci 0000:03:00.0: no channel configured; ignoring frame(s)!
>          <until ratelimit kicks in>
>          ath10k_warn: 155 callbacks suppressed

[]

> diff --git a/drivers/net/wireless/ath/ath10k/htt_rx.c b/drivers/net/wireless/ath/ath10k/htt_rx.c
[]
> @@ -1514,7 +1514,7 @@ static bool ath10k_htt_rx_amsdu_allowed(struct ath10k *ar,
>           */
> 
>          if (!rx_status->freq) {
> -               ath10k_warn(ar, "no channel configured; ignoring frame(s)!\n");
> +               ath10k_dbg(ar, ATH10K_DBG_HTT, "no channel configured; ignoring frame(s)!\n");
>                  return false;
>          }

Hi.  This doesn't apply because of tab to space conversions.

Please use git send-email to send your patch.

Maybe read Documentation/process/email-clients.rst
