From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] smsc95xx: fix error handling in suspend failure
 case
Date: Wed, 28 Nov 2012 21:04:41 -0500 (EST)
Message-ID: <20121128.210441.347806091375937919.davem@davemloft.net>
References: <1354124819-29531-1-git-send-email-steve.glendinning@shawell.net>
	<1354124819-29531-3-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55065 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752814Ab2K2CEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 21:04:42 -0500
In-Reply-To: <1354124819-29531-3-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@shawell.net>
Date: Wed, 28 Nov 2012 17:46:58 +0000

> -		check_warn_return(ret, "Error reading WUCSR\n");
> +		check_warn_goto_done(ret, "Error reading WUCSR\n");

This is just another example of how error prone these macros
are, kill them.
