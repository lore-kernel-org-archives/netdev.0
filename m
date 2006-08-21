From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 5/7] ieee80211: export symbol ieee80211_api_version
Date: Mon, 21 Aug 2006 06:38:27 -0400
Message-ID: <1156156707.5729.21.camel@localhost.localdomain>
References: <20060821033340.GA4802@mail.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:31714 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751847AbWHUKaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 06:30:21 -0400
To: yi.zhu@intel.com
In-Reply-To: <20060821033340.GA4802@mail.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-08-21 at 11:33 +0800, Zhu Yi wrote:
> Export this symbol so that wireless drivers can check the running IEEE80211
> API version dynamically.

What's that needed for?  Capability checks?  Checking user's version to
ensure they have a version with security fixes?

What API bits changed?

Dan

> Signed-off-by: Zhu Yi <yi.zhu@intel.com>
> 
> ---
> 
>  include/net/ieee80211.h          |    2 ++
>  net/ieee80211/ieee80211_module.c |    3 +++
>  2 files changed, 5 insertions(+), 0 deletions(-)
> 
> 81634e488965fae232027e14a54c998ccb5b0c49
> diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
> index 83e06aa..ee66681 100644
> --- a/include/net/ieee80211.h
> +++ b/include/net/ieee80211.h
> @@ -1255,6 +1255,8 @@ static inline int ieee80211_is_cck_rate(
>  	return 0;
>  }
>  
> +extern const int ieee80211_api_version;
> +
>  /* ieee80211.c */
>  extern void free_ieee80211(struct net_device *dev);
>  extern struct net_device *alloc_ieee80211(int sizeof_priv);
> diff --git a/net/ieee80211/ieee80211_module.c b/net/ieee80211/ieee80211_module.c
> index 13b1e5f..02e730b 100644
> --- a/net/ieee80211/ieee80211_module.c
> +++ b/net/ieee80211/ieee80211_module.c
> @@ -61,6 +61,9 @@ MODULE_DESCRIPTION(DRV_DESCRIPTION);
>  MODULE_AUTHOR(DRV_COPYRIGHT);
>  MODULE_LICENSE("GPL");
>  
> +const int ieee80211_api_version = IEEE80211_VERSION_API;
> +EXPORT_SYMBOL(ieee80211_api_version);
> +
>  static int ieee80211_networks_allocate(struct ieee80211_device *ieee)
>  {
>  	if (ieee->networks)

