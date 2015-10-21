From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 11/15] net: wireless: iwlegacy: Remove unneeded variable
 ret
Date: Thu, 22 Oct 2015 00:45:41 +0300
Message-ID: <56280785.4050503@cogentembedded.com>
References: <1445439337-19055-1-git-send-email-punitvara@gmail.com>
 <1445439337-19055-12-git-send-email-punitvara@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stas.yakovlev@gmail.com, chaoming_li@realsil.com.cn,
	Larry.Finger@lwfinger.net, chunkeey@googlemail.com,
	sgruszka@redhat.com, brudley@broadcom.com, arend@broadcom.com,
	linville@tuxdriver.com, jirislaby@gmail.com, mickflemm@gmail.com,
	mcgrof@do-not-panic.com, k.eugene.e@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, wcn36xx@lists.infradead.org,
	johannes.berg@intel.com, meuleman@broadcom.com
To: Punit Vara <punitvara@gmail.com>, kvalo@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445439337-19055-12-git-send-email-punitvara@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/2015 05:55 PM, Punit Vara wrote:

> This patch is to the 3945-mac.c file that fixes up following warning
> by coccicheck:
>
> drivers/net/wireless/iwlegacy/3945-mac.c:247:5-8: Unneeded variable:
> "ret". Return "- EOPNOTSUPP" on line 249
>
> Return -EOPNOTSUPP directly instead of return using ret
>
> Signed-off-by: Punit Vara <punitvara@gmail.com>
> ---
>   drivers/net/wireless/iwlegacy/3945-mac.c | 5 +----
>   1 file changed, 1 insertion(+), 4 deletions(-)
>
> diff --git a/drivers/net/wireless/iwlegacy/3945-mac.c b/drivers/net/wireless/iwlegacy/3945-mac.c
> index af1b3e6..ff4dc44 100644
> --- a/drivers/net/wireless/iwlegacy/3945-mac.c
> +++ b/drivers/net/wireless/iwlegacy/3945-mac.c
[...]
> @@ -529,7 +527,6 @@ il3945_tx_skb(struct il_priv *il,
>   		if (unlikely(tid >= MAX_TID_COUNT))
>   			goto drop;
>   	}
> -

    Unrelated whitespace change.

>   	/* Descriptor for chosen Tx queue */
>   	txq = &il->txq[txq_id];
>   	q = &txq->q;

MBR, Sergei
