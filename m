From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 3/3] mac80211: support bpf monitor filter
Date: Thu, 13 Apr 2017 08:00:18 +0200
Message-ID: <1492063218.19193.2.camel@sipsolutions.net>
References: <20170412110726.9689-1-johannes@sipsolutions.net>
         <20170412110726.9689-3-johannes@sipsolutions.net>
         (sfid-20170412_130907_870638_0C9870E2)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:50084 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751400AbdDMGAV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 02:00:21 -0400
In-Reply-To: <20170412110726.9689-3-johannes@sipsolutions.net> (sfid-20170412_130907_870638_0C9870E2)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> @@ -551,6 +551,9 @@ struct ieee80211_hw *ieee80211_alloc_hw_nm(size_t
> priv_data_len,
>  			   NL80211_FEATURE_FULL_AP_CLIENT_STATE;
>  	wiphy_ext_feature_set(wiphy, NL80211_EXT_FEATURE_FILS_STA);
>  
> +	if (IS_ENABLED(CONFIG_BPF_WIFIMON))
> +		wiphy_ext_feature_isset(wiphy,
> NL80211_EXT_FEATURE_WIFIMON_BPF);
> 
That obviously needs to be _set(), not _isset().

johannes
