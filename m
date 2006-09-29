From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATH] Allow mtu bigger than 1500 for ieee80211
Date: Fri, 29 Sep 2006 09:38:21 +0200
Message-ID: <1159515501.2644.3.camel@ux156>
References: <451C0D05.4050705@free.fr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:40863 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S965062AbWI2Hhg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 03:37:36 -0400
To: matthieu castet <castet.matthieu@free.fr>
In-Reply-To: <451C0D05.4050705@free.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-09-28 at 19:57 +0200, matthieu castet wrote:

> +	if ((new_mtu < 68) || (new_mtu > IEEE80211_DATA_LEN))
> +		return -EINVAL;

What's with that lower limit, why 68?

johannes
