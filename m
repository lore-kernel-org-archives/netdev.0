From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next v9 2/9] net: nl80211 - make
 rdev_add_virtual_intf take name_assign_type
Date: Thu, 17 Jul 2014 11:04:15 +0200
Message-ID: <1405587855.20120.0.camel@jlt4.sipsolutions.net>
References: <1405584370-30054-1-git-send-email-teg@jklm.no>
	 <1405584370-30054-3-git-send-email-teg@jklm.no>
	 (sfid-20140717_101259_938095_1A8DB91D)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	John Linville <linville@tuxdriver.com>
To: Tom Gundersen <teg@jklm.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:53041 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756428AbaGQJEf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2014 05:04:35 -0400
In-Reply-To: <1405584370-30054-3-git-send-email-teg@jklm.no> (sfid-20140717_101259_938095_1A8DB91D)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-17 at 10:06 +0200, Tom Gundersen wrote:
> Pass the value down and set it at the same place the name itself is set.

Huh? What's this? Can you explain why?

>  static struct wireless_dev *ath6kl_cfg80211_add_iface(struct wiphy *wiphy,
>  						      const char *name,
> +						      unsigned char name_assign_type,

unsigned char for an enum is really odd.

johannes
