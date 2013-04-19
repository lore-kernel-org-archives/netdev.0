From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rate-limit warn-bad-offload splats.
Date: Fri, 19 Apr 2013 17:58:47 -0400 (EDT)
Message-ID: <20130419.175847.2037489757817828171.davem@davemloft.net>
References: <1366404352-14134-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48870 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933335Ab3DSV6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 17:58:49 -0400
In-Reply-To: <1366404352-14134-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: greearb@candelatech.com
Date: Fri, 19 Apr 2013 13:45:52 -0700

> From: Ben Greear <greearb@candelatech.com>
> 
> If one does do something unfortunate and allow a
> bad offload bug into the kernel, this the
> skb_warn_bad_offload can effectively live-lock the
> system, filling the logs with the same error over
> and over.
> 
> Add rate limitation to this so that box remains otherwise
> functional in this case.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

Applied, thanks Ben.
