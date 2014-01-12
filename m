From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/5] alx: add statistics
Date: Sat, 11 Jan 2014 20:54:06 -0800 (PST)
Message-ID: <20140111.205406.755147537326008945.davem@davemloft.net>
References: <1389258571-10083-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, johannes@sipsolutions.net,
	stephen@networkplumber.org, netdev@vger.kernel.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53008 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbaALEyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 23:54:07 -0500
In-Reply-To: <1389258571-10083-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Thu,  9 Jan 2014 10:09:26 +0100

> Currently, the alx driver doesn't support statistics [1,2]. The
> original alx driver [3] that Johannes Berg modified provided
> statistics. This patch is an adaptation of the statistics code from
> the original driver to the alx driver included in the kernel.
> 
> v4:
>  - modified the assignements of hw stats to netstats (Ben Hutchings)
>  - added comments to describe the stats fields (copied from atlx)
> 
> v3:
>  - renamed __alx_update_hw_stats to alx_update_hw_stats (Stephen Hemminger)
> 
> v2:
>  - use u64 instead of unsigned long  (Ben Hutchings)
>  - implement ndo_get_stats64 instead of ndo_get_stats (Ben Hutchings)
>  - use EINVAL instead of ENOTSUPP  (Ben Hutchings)
>  - add BUILD_BUG_ON to check the size of the stats (Johannes Berg, Ben
>    Hutchings)
>  - add a comment regarding persistence of the stats (Stephen Hemminger)
>  - align assignments in __alx_update_hw_stats
> 
> 
> [1] https://bugzilla.kernel.org/show_bug.cgi?id=63401
> [2] http://www.spinics.net/lists/netdev/msg245544.html
> [3] https://github.com/mcgrof/alx

Series applied to net-next, thanks.
