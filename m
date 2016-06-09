From: Amitkumar Karwar <akarwar@marvell.com>
Subject: RE: [PATCH 1/1] mwifiex: illegal assignment
Date: Thu, 9 Jun 2016 13:22:09 +0000
Message-ID: <66189faafe0e477da81a03677d56ef69@SC-EXCH04.marvell.com>
References: <1463526118-11822-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Heinrich Schuchardt <xypron.glpk@gmx.de>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016f401.pphosted.com ([67.231.156.173]:53386 "EHLO
	mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751168AbcFINWR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 09:22:17 -0400
In-Reply-To: <1463526118-11822-1-git-send-email-xypron.glpk@gmx.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Heinrich Schuchardt [mailto:xypron.glpk@gmx.de]
> Sent: Wednesday, May 18, 2016 4:32 AM
> To: Amitkumar Karwar; Nishant Sarmukadam; Kalle Valo
> Cc: Xinming Hu; Cathy Luo; linux-wireless@vger.kernel.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Heinrich
> Schuchardt
> Subject: [PATCH 1/1] mwifiex: illegal assignment
> 
> Variable adapter is incorrectly initialized.
> 
> Fixes: bf00dc22bc7a ("mwifiex: AMSDU Rx frame handling in AP mode")
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
> ---
>  drivers/net/wireless/marvell/mwifiex/uap_txrx.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/marvell/mwifiex/uap_txrx.c
> b/drivers/net/wireless/marvell/mwifiex/uap_txrx.c
> index 666e91a..bf5660e 100644
> --- a/drivers/net/wireless/marvell/mwifiex/uap_txrx.c
> +++ b/drivers/net/wireless/marvell/mwifiex/uap_txrx.c
> @@ -272,7 +272,7 @@ int mwifiex_handle_uap_rx_forward(struct
> mwifiex_private *priv,  int mwifiex_uap_recv_packet(struct
> mwifiex_private *priv,
>  			    struct sk_buff *skb)
>  {
> -	struct mwifiex_adapter *adapter = adapter;
> +	struct mwifiex_adapter *adapter = priv->adapter;
>  	struct mwifiex_sta_node *src_node;
>  	struct ethhdr *p_ethhdr;
>  	struct sk_buff *skb_uap;
> --
> 2.1.4

Acked-by: Amitkumar Karwar <akarwar@marvell.com>

Regards,
Amitkumar
