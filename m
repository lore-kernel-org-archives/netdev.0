From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH 4/4] brcmfmac: set NET_NAME_USER for P2P ifs
Date: Thu, 27 Feb 2014 18:30:22 +0100
Message-ID: <530F762E.6030301@broadcom.com>
References: <1393512434-1325-1-git-send-email-dh.herrmann@gmail.com> <1393512434-1325-5-git-send-email-dh.herrmann@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Tom Gundersen <teg@jklm.no>,
	Johannes berg <johannes@sipsolutions.net>,
	<linux-kernel@vger.kernel.org>, <linux-wireless@vger.kernel.org>
To: David Herrmann <dh.herrmann@gmail.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393512434-1325-5-git-send-email-dh.herrmann@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/27/2014 03:47 PM, David Herrmann wrote:
> Netdevs created via nl80211 (currently only P2P ifs) have names provided
> by user-space. Therefore, set the naming-policy to NET_NAME_USER so it is
> correctly shown in sysfs.
> 
- Cc: Arend van Spriel <arend@broadcom.com>
+ Acked-by: Arend van Spriel <arend@broadcom.com>

> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
> ---
>  drivers/net/wireless/brcm80211/brcmfmac/p2p.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
> index fc4f98b..6af4d26 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
> @@ -2310,6 +2310,7 @@ struct wireless_dev *brcmf_p2p_add_vif(struct wiphy *wiphy, const char *name,
>  		goto fail;
>  	}
>  
> +	ifp->ndev->name_assign_type = NET_NAME_USER;
>  	strncpy(ifp->ndev->name, name, sizeof(ifp->ndev->name) - 1);
>  	err = brcmf_net_attach(ifp, true);
>  	if (err) {
> 
