From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [TIPC] Fixed skb_under_panic caused by
 tipc_link_bundle_buf
Date: Mon, 03 Jul 2006 19:39:56 -0700 (PDT)
Message-ID: <20060703.193956.28783568.davem@davemloft.net>
References: <Pine.LNX.4.64.0606291703270.1695@ulinpc219.uab.ericsson.se>
	<20060629.124142.102573938.davem@davemloft.net>
	<Pine.LNX.4.64.0606301032170.17932@ulinpc219.uab.ericsson.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36039
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751330AbWGDCjl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 22:39:41 -0400
To: per.liden@ericsson.com
In-Reply-To: <Pine.LNX.4.64.0606301032170.17932@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Per Liden <per.liden@ericsson.com>
Date: Fri, 30 Jun 2006 10:49:08 +0200 (CEST)

> [TIPC] Fixed sk_buff panic caused by tipc_link_bundle_buf (REVISED)
> 
> From: Allan Stephens <allan.stephens@windriver.com>
> 
> The recent change to direct inspection of bundle buffer tailroom did not
> account for the possiblity of unrequested tailroom added by skb_alloc(),
> thereby allowing a bundle to be created that exceeds the current link MTU.
> An additional check now ensures that bundling works correctly no matter
> if the bundle buffer is smaller, larger, or equal to the link MTU.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Per Liden <per.liden@ericsson.com>

Applied, thanks a lot Per.
