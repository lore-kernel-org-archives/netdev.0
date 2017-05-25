From: Sergey Matyukevich <sergey.matyukevich.os@quantenna.com>
Subject: Re: [PATCH][net-next] qtnfmac: remove duplicated assignment to mac
Date: Thu, 25 May 2017 16:56:24 +0300
Message-ID: <20170525135624.z723srd7evhml5e3@bars>
References: <20170525134503.12106-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Avinash Patil <avinashp@quantenna.com>,
        Sergey Matyukevich <sergey.matyukevich.os@quantenna.com>,
        Igor Mitsyanko <igor.mitsyanko.os@quantenna.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Huizhao Wang <hwang@quantenna.com>,
        Kamlesh Rath <krath@quantenna.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170525134503.12106-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> mac is being assigned twice, remove redundant 2nd assignment.
> 
> Detected by CoverityScan, CID#1437554 ("Incorrect expression")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/wireless/quantenna/qtnfmac/cfg80211.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/quantenna/qtnfmac/cfg80211.c b/drivers/net/wireless/quantenna/qtnfmac/cfg80211.c
> index fc0ce2c09097..e3c090008125 100644
> --- a/drivers/net/wireless/quantenna/qtnfmac/cfg80211.c
> +++ b/drivers/net/wireless/quantenna/qtnfmac/cfg80211.c
> @@ -922,7 +922,7 @@ void qtnf_netdev_updown(struct net_device *ndev, bool up)
>  void qtnf_virtual_intf_cleanup(struct net_device *ndev)
>  {
>         struct qtnf_vif *vif = qtnf_netdev_get_priv(ndev);
> -       struct qtnf_wmac *mac = mac = wiphy_priv(vif->wdev.wiphy);
> +       struct qtnf_wmac *mac = wiphy_priv(vif->wdev.wiphy);

Thanks !

Acked-by: Sergey Matyukevich <sergey.matyukevich.os@quantenna.com>
