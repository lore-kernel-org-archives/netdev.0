From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 0/2] wireless: Make and use const struct ieee80211_channel
Date: Thu, 5 May 2011 14:49:34 -0400
Message-ID: <20110505184934.GB3005@tuxdriver.com>
References: <cover.1304054543.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, libertas-dev@lists.infradead.org,
	orinoco-users@lists.sourceforge.net,
	orinoco-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1304054543.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches generated a lot of warnings in net/mac80211.  Did you
actually build them?

On Thu, Apr 28, 2011 at 10:25:06PM -0700, Joe Perches wrote:
> Joe Perches (2):
>   wireless: Make struct ieee80211_channel const where possible
>   wireless: Use const struct ieee80211_channel where possible
> 
>  drivers/net/wireless/iwlegacy/iwl-4965-lib.c |    2 +-
>  drivers/net/wireless/iwlegacy/iwl3945-base.c |    2 +-
>  drivers/net/wireless/iwlwifi/iwl-agn-lib.c   |    2 +-
>  drivers/net/wireless/iwmc3200wifi/cfg80211.c |    4 +-
>  drivers/net/wireless/libertas/cfg.c          |    2 +-
>  drivers/net/wireless/mwifiex/cfg80211.c      |    9 ++++---
>  drivers/net/wireless/orinoco/cfg.c           |    2 +-
>  drivers/net/wireless/rndis_wlan.c            |    9 ++++---
>  drivers/net/wireless/wl1251/cmd.c            |    2 +-
>  drivers/net/wireless/wl1251/cmd.h            |    2 +-
>  include/net/cfg80211.h                       |   34 +++++++++++++-------------
>  net/wireless/chan.c                          |   10 ++++----
>  net/wireless/core.h                          |   14 ++++++----
>  net/wireless/debugfs.c                       |    2 +-
>  net/wireless/ibss.c                          |    6 ++--
>  net/wireless/mlme.c                          |   15 ++++++-----
>  net/wireless/nl80211.c                       |   31 ++++++++++++-----------
>  net/wireless/nl80211.h                       |    9 ++++---
>  net/wireless/reg.c                           |   11 ++++----
>  net/wireless/reg.h                           |    4 +-
>  net/wireless/scan.c                          |    6 ++--
>  net/wireless/wext-sme.c                      |    2 +-
>  22 files changed, 94 insertions(+), 86 deletions(-)
> 
> -- 
> 1.7.5.rc3.dirty
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
