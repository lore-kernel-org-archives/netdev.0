From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 16/18] d80211:  get rid of MICHAEL_MIC_HWACCEL define
Date: Tue, 22 Aug 2006 21:00:38 +0200
Message-ID: <20060822210038.53ee194c@griffin.suse.cz>
References: <20060821074107.648561364@sipsolutions.net>
	<20060821075202.538664376@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:13502 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1750879AbWHVTAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 15:00:39 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <20060821075202.538664376@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Aug 2006 09:41:23 +0200, Johannes Berg wrote:
> The symbol MICHAEL_MIC_HWACCEL is always defined and hence
> all the ifdefs using it are useless. This patch removes it.
> 
> [...]
> @@ -87,9 +84,7 @@ ieee80211_tx_h_michael_mic_add(struct ie
>  	u16 fc;
>  	struct sk_buff *skb = tx->skb;
>  	int authenticator;
> -#if defined(CONFIG_HOSTAPD_WPA_TESTING) || defined(MICHAEL_MIC_HWACCEL)
>  	int wpa_test = 0;
> -#endif

When you're touching this, could you #ifdef out wpa_test when
CONFIG_HOSTAPD_WPA_TESTING is not defined? This could be a part of this
patch.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
