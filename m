From: Bob Copeland <me@bobcopeland.com>
Subject: Re: [PATCH 4/4] mac80211: sta_info: max_peers reached falsely
Date: Tue, 28 Jun 2016 08:56:21 -0400
Message-ID: <20160628125621.GA9223@localhost>
References: <20160628111307.8784-1-yanivma@ti.com>
 <20160628111307.8784-2-yanivma@ti.com>
 <20160628111307.8784-3-yanivma@ti.com>
 <20160628111307.8784-4-yanivma@ti.com>
 <20160628111307.8784-5-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S . Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Meirav Kama <meiravk@ti.com>
To: Yaniv Machani <yanivma@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160628111307.8784-5-yanivma@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 28, 2016 at 02:13:07PM +0300, Yaniv Machani wrote:
> From: Meirav Kama <meiravk@ti.com>
> 
> Issue happened when receiving delete_sta command without
> changing plink_state from ESTAB to HOLDING before.
> When receiving delete_sta command for mesh interface
> verify plink_state is not ESTAB and if so, decrease
> plink count and update beacon.

This should be fixed already (and properly) by the patch
"mac80211: Fix mesh estab links counting" -- please let us
know if you have a case that's still broken with that fix.

-- 
Bob Copeland %% http://bobcopeland.com/
