From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 3/5] d80211: fix interface removal
Date: Wed, 23 Aug 2006 09:20:28 +0200
Message-ID: <1156317628.3629.13.camel@ux156>
References: <20060822173241.313859000@devicescape.com>
	 <20060822173353.GD12500@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:9939 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751427AbWHWHT7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 03:19:59 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20060822173353.GD12500@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-22 at 10:33 -0700, David Kimdon wrote:
> +	if (param->u.if_info.type == HOSTAP_IF_WDS) {
> +		type = IEEE80211_IF_TYPE_WDS;
> +	} else if (param->u.if_info.type == HOSTAP_IF_VLAN) {
> +		type = IEEE80211_IF_TYPE_VLAN;
> +	} else if (param->u.if_info.type == HOSTAP_IF_BSS) {
> +		type = IEEE80211_IF_TYPE_AP;
> +	} else if (param->u.if_info.type == HOSTAP_IF_STA) {
> +		type = IEEE80211_IF_TYPE_STA;
> +	} else {
> +        return -EINVAL;
>  	}

IMHO that'd look better as a switch(). Or maybe even a small static
array to map them and just some bounds checking code?

Also, spaces instead of tab on the last added line.

johannes
