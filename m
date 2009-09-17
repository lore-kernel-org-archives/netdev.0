From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] wl12xx: switch to %pM to print the mac address
Date: Thu, 17 Sep 2009 02:22:51 +0100
Message-ID: <1253150571.4989.33.camel@localhost>
References: <1253146059-4169-1-git-send-email-plagnioj@jcrosoft.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:26943 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754551AbZIQBiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 21:38:09 -0400
In-Reply-To: <1253146059-4169-1-git-send-email-plagnioj@jcrosoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-09-17 at 02:07 +0200, Jean-Christophe PLAGNIOL-VILLARD
wrote:
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

That isn't even syntactically valid, let alone correct.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

