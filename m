From: Pavel Roskin <proski@gnu.org>
Subject: Re: [ath5k-devel] [PATCH 3/5] ath5k: Add missing breaks in switch/case
Date: Mon, 11 Jul 2011 11:50:33 -0400
Message-ID: <4E1B1BC9.3080601@gnu.org>
References: <cover.1310289795.git.joe@perches.com> <e554bed5c753a3fe85d3be34983a15e6110a6e35.1310289795.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Bob Copeland <me@bobcopeland.com>, netdev@vger.kernel.org,
	ath5k-devel@lists.ath5k.org, linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c60.cesmail.net ([216.154.195.49]:33020 "EHLO c60.cesmail.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757776Ab1GKPuf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 11:50:35 -0400
In-Reply-To: <e554bed5c753a3fe85d3be34983a15e6110a6e35.1310289795.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/2011 05:28 AM, Joe Perches wrote:
> Signed-off-by: Joe Perches<joe@perches.com>

Acked-by: Pavel Roskin <proski@gnu.org>

> ---
>   drivers/net/wireless/ath/ath5k/desc.c |    3 +++
>   1 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/ath5k/desc.c b/drivers/net/wireless/ath/ath5k/desc.c
> index 62172d5..f82383b 100644
> --- a/drivers/net/wireless/ath/ath5k/desc.c
> +++ b/drivers/net/wireless/ath/ath5k/desc.c
> @@ -107,10 +107,13 @@ ath5k_hw_setup_2word_tx_desc(struct ath5k_hw *ah, struct ath5k_desc *desc,
>   		case AR5K_PKT_TYPE_BEACON:
>   		case AR5K_PKT_TYPE_PROBE_RESP:
>   			frame_type = AR5K_AR5210_TX_DESC_FRAME_TYPE_NO_DELAY;
> +			break;
>   		case AR5K_PKT_TYPE_PIFS:
>   			frame_type = AR5K_AR5210_TX_DESC_FRAME_TYPE_PIFS;
> +			break;
>   		default:
>   			frame_type = type;
> +			break;
>   		}

The intention here is to replace frame types from enum ath5k_pkt_type 
with their AR5210-specific counterparts.  So the intention is definitely 
to have breaks here.

Unfortunately, AR5210 cards are extremely rare these days.  I have one, 
but it only works with old motherboards.  It would take me half a day to 
dust off that system, compile the kernel and check the patch.  But I 
assume your patch is fine.  At least it's very unlikely to break anything.

-- 
Regards,
Pavel Roskin
