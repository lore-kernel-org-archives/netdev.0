From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] add nl80211
Date: Tue, 22 Aug 2006 17:09:42 +0200
Message-ID: <1156259382.3825.6.camel@ux156>
References: <1156254768.3825.1.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:38793 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932305AbWHVPJQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 11:09:16 -0400
To: netdev <netdev@vger.kernel.org>
In-Reply-To: <1156254768.3825.1.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-22 at 15:52 +0200, Johannes Berg wrote:
> +	/* make it complain if wiphy is set and is different or invalid */
> +	if (info->attrs[NL80211_ATTR_IFINDEX]) {
> +		wiphy = nla_get_u32(info->attrs[NL80211_ATTR_IFINDEX]);

That's what you get for writing code too quickly ;)
Both of these should be NL80211_ATTR_WIPHY of course!

johannes
