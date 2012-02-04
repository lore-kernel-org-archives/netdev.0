From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netprio_cgroup: Fix obo in get_prioidx
Date: Sat, 04 Feb 2012 16:31:00 -0500 (EST)
Message-ID: <20120204.163100.1902018364644947001.davem@davemloft.net>
References: <1328282323-15902-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sgruszka@redhat.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36196 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754203Ab2BDVcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 16:32:07 -0500
In-Reply-To: <1328282323-15902-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri,  3 Feb 2012 10:18:43 -0500

> It was recently pointed out to me that the get_prioidx function sets a bit in
> the prioidx map prior to checking to see if the index being set is out of
> bounds.  This patch corrects that, avoiding the possiblity of us writing beyond
> the end of the array
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Stanislaw Gruszka <sgruszka@redhat.com>

Applied and queued up for -stable, thanks Neil.
