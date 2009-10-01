From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/3] wireless: implement basic ethtool support for
 cfg80211 devices
Date: Thu, 01 Oct 2009 02:30:38 +0100
Message-ID: <1254360638.23350.0.camel@localhost>
References: <20091001011340.GA3123@tuxdriver.com>
	 <1254359942-3483-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Kalle Valo <kalle.valo@nokia.com>,
	Kalle Valo <kalle.valo@iki.fi>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:20845 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755332AbZJABal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 21:30:41 -0400
In-Reply-To: <1254359942-3483-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-09-30 at 21:19 -0400, John W. Linville wrote:
[...]
> +void cfg80211_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
> +{
> +	struct wireless_dev *wdev = dev->ieee80211_ptr;
> +
> +	strncpy(info->driver, wiphy_dev(wdev->wiphy)->driver->name,
> +		sizeof(info->driver));
> +	info->driver[sizeof(info->driver) - 1] = '\0';
[...]

Use strlcpy() instead of these two statements.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

