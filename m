From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] Changes to ieee80211.h for user space regulatory daemon
Date: Mon, 5 Jun 2006 14:59:10 -0400
Message-ID: <20060605185905.GH6068@tuxdriver.com>
References: <447C790E.1030702@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:30217 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751298AbWFES7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 14:59:18 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <447C790E.1030702@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2006 at 11:55:42AM -0500, Larry Finger wrote:
> Attached are two small patches for include/net/ieee80211.h to prepare for 
> later submission of code to implement a user-space daemon that supplies 
> 802.11 regulatory information.
> 
> The first change adds a bit indicating that 802.11h rules are to be applied 
> to a channel. As discussed earlier in this list, a single bit is unlikely 

> @@ -968,6 +968,7 @@ #define IEEE80211_52GHZ_CHANNELS (IEEE80
> 
>  enum {
> 	IEEE80211_CH_PASSIVE_ONLY = (1 << 0),
> +	IEEE80211_CH_80211H_RULES = (1 << 1),
> 	IEEE80211_CH_B_ONLY = (1 << 2),
> 	IEEE80211_CH_NO_IBSS = (1 << 3),
> 	IEEE80211_CH_UNIFORM_SPREADING = (1 << 4),

Any idea why this "hole" was here to begin with?  Was there something
else defined as (1 << 1) previously?  Is it safe to reuse this value?

John
-- 
John W. Linville
linville@tuxdriver.com
