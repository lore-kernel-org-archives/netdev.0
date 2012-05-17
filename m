From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] drop_monitor: convert to modular building
Date: Thu, 17 May 2012 16:09:37 -0400 (EDT)
Message-ID: <20120517.160937.586334759945738635.davem@davemloft.net>
References: <1337178426-2470-1-git-send-email-nhorman@tuxdriver.com>
	<1337285040-20848-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34574 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966008Ab2EQUKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 16:10:45 -0400
In-Reply-To: <1337285040-20848-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 17 May 2012 16:04:00 -0400

> When I first wrote drop monitor I wrote it to just build monolithically.  There
> is no reason it can't be built modularly as well, so lets give it that
> flexibiity.
> 
> I've tested this by building it as both a module and monolithically, and it
> seems to work quite well
> 
> Change notes:
> 
> v2)
> * fixed for_each_present_cpu loops to be more correct as per Eric D.
> * Converted exit path failures to BUG_ON as per Ben H.
> 
> v3)
> * Converted del_timer to del_timer_sync to close race noted by Ben H.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied, althrough it didn't apply cleanly to net-next.
