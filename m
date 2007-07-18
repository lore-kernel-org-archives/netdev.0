From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] mac80211: fix GCC warning on 64bit platforms
Date: Wed, 18 Jul 2007 15:29:14 -0700 (PDT)
Message-ID: <20070718.152914.04054726.davem@davemloft.net>
References: <20070716184653.355253bf@griffin.suse.cz>
	<20070716.145358.35015496.davem@davemloft.net>
	<20070718171044.2de287cd@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57936
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752446AbXGRW3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 18:29:15 -0400
In-Reply-To: <20070718171044.2de287cd@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Benc <jbenc@suse.cz>
Date: Wed, 18 Jul 2007 17:10:44 +0200

> -	local->tx_headroom = max(local->hw.extra_tx_headroom,
> -				 sizeof(struct ieee80211_tx_status_rtap_hdr));
> +	local->tx_headroom = max_t(unsigned, local->hw.extra_tx_headroom,
> +				   sizeof(struct ieee80211_tx_status_rtap_hdr));

Please spell out the complete type, "unsigned int".
