From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 11/18] d80211:  clean up qdisc requeue
Date: Mon, 21 Aug 2006 21:31:04 +0200
Message-ID: <20060821213104.56cdd40f@griffin.suse.cz>
References: <20060821074107.648561364@sipsolutions.net>
	<20060821075200.982958463@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:8157 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1750879AbWHUTbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 15:31:07 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <20060821075200.982958463@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Aug 2006 09:41:18 +0200, Johannes Berg wrote:
> There was a comment saying:
> /* TODO: clean up the cases where master_hard_start_xmit
>  * returns non 0 - it shouldn't ever do that. Once done we
>  * can remove this function */
> 
> I noticed that master_hard_start_xmit never returns nonzero
> by following the paths it calls. This patch hence removes
> the function and changes a few things to make the fact that
> it always returns 0 more obvious.

Please do not do this. The plan is to move most processing from tx path
to 802.11 qdisc dequeue function and then 0 will be a valid return code
from ieee80211_tx.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
