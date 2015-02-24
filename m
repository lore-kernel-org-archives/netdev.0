From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] nl80211: Fix possible leak in nl80211_new_interface on
 MONITOR_FLAG_ACTIVE
Date: Tue, 24 Feb 2015 10:58:12 +0100
Message-ID: <1424771892.2192.9.camel@sipsolutions.net>
References: <1423943521-2896-1-git-send-email-cengelma@gmx.at>
	 (sfid-20150214_205224_679047_9F3F20CE)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Christian Engelmayer <cengelma@gmx.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:37997 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751314AbbBXJ6Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 04:58:25 -0500
In-Reply-To: <1423943521-2896-1-git-send-email-cengelma@gmx.at> (sfid-20150214_205224_679047_9F3F20CE)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-02-14 at 20:52 +0100, Christian Engelmayer wrote:
> In case of NL80211_IFTYPE_MONITOR and flag MONITOR_FLAG_ACTIVE, the already
> allocated sk_buff 'msg' is not freed, when the function exits in case the
> feature is not supported. Detected by Coverity CID 1269116.
> 
> Signed-off-by: Christian Engelmayer <cengelma@gmx.at>
> ---
> Compile tested only. Applies against linux-next.

Thanks for the report. I've fixed this in a different way.

johannes
