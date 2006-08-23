From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] add nl80211
Date: Wed, 23 Aug 2006 11:40:36 +0200
Message-ID: <1156326036.3914.0.camel@ux156>
References: <1156254768.3825.1.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:45205 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751501AbWHWJkZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 05:40:25 -0400
To: netdev <netdev@vger.kernel.org>
In-Reply-To: <1156254768.3825.1.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-22 at 15:52 +0200, Johannes Berg wrote:
> +		dev = dev_get_by_index(ifindex);
> +		result = nl80211_drv_by_priv_locked(dev->ieee80211_ptr);
> +		dev_put(dev);
> +		if (result)
> +			return result;
> +		err = -ENODEV;

Doh, bug (not checking dev != NULL) fixed in my local patch, will submit
new ones later.

johannes
