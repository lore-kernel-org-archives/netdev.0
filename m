From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/4] mac80211: mesh: flush stations before beacons are
 stopped
Date: Wed, 29 Jun 2016 09:14:19 +0200
Message-ID: <1467184459.2461.1.camel@sipsolutions.net>
References: <20160628111307.8784-1-yanivma@ti.com>
	 <20160628111307.8784-2-yanivma@ti.com>
	 (sfid-20160628_131058_738638_5F9A964D)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Maital Hahn <maitalm@ti.com>
To: Yaniv Machani <yanivma@ti.com>, linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:50452 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751184AbcF2HOX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 03:14:23 -0400
In-Reply-To: <20160628111307.8784-2-yanivma@ti.com> (sfid-20160628_131058_738638_5F9A964D)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-06-28 at 14:13 +0300, Yaniv Machani wrote:
> From: Maital Hahn <maitalm@ti.com>
> 
> Some drivers (e.g. wl18xx) expect that the last stage in the
> de-initialization process will be stopping the beacons, similar to
> ap. Update ieee80211_stop_mesh() flow accordingly.
> 
How well have you tested that with other drivers?

Changing behaviour to something a single driver desires isn't
necessarily the best thing to do, since there always are multiple
drivers.

If you're able to demonstrate that it works with the other drivers I'm
willing to take that - the change makes sense after all, and it seems
drivers must support this ordering since peers are also removed
dynamically... But still. Don't just make a change like that without
even giving any indication why you think it's fine for other drivers!

johannes
