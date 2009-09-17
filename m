From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 1/2] wl12xx: switch to %pM to print the mac address
Date: Wed, 16 Sep 2009 20:28:52 -0400
Message-ID: <20090917002852.GE14393@tuxdriver.com>
References: <1253146059-4169-1-git-send-email-plagnioj@jcrosoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38483 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755417AbZIQAab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 20:30:31 -0400
Content-Disposition: inline
In-Reply-To: <1253146059-4169-1-git-send-email-plagnioj@jcrosoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2009 at 02:07:38AM +0200, Jean-Christophe PLAGNIOL-VILLARD wrote:
> Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> ---
>  drivers/net/wireless/wl12xx/wl1271_main.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/wl12xx/wl1271_main.c b/drivers/net/wireless/wl12xx/wl1271_main.c
> index d9169b4..f6f8895 100644
> --- a/drivers/net/wireless/wl12xx/wl1271_main.c
> +++ b/drivers/net/wireless/wl12xx/wl1271_main.c
> @@ -644,11 +644,10 @@ static int wl1271_op_config_interface(struct ieee80211_hw *hw,
>  {
>  	struct wl1271 *wl = hw->priv;
>  	struct sk_buff *beacon;
> -	DECLARE_MAC_BUF(mac);
>  	int ret;
>  
>  	wl1271_debug(DEBUG_MAC80211, "mac80211 config_interface bssid %s",
> -		     print_mac(mac, conf->bssid));
> +		     printf("%pM", conf->bssid);
>  	wl1271_dump_ascii(DEBUG_MAC80211, "ssid: ", conf->ssid,
>  			  conf->ssid_len);
>  

ACK

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
