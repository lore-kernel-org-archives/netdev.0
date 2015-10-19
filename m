From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tunnels: Don't require remote endpoint or ID
 during creation.
Date: Sun, 18 Oct 2015 22:44:39 -0700 (PDT)
Message-ID: <20151018.224439.2162951217660850579.davem@davemloft.net>
References: <1445038560-85471-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49472 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbbJSF2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 01:28:21 -0400
In-Reply-To: <1445038560-85471-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Fri, 16 Oct 2015 16:36:00 -0700

> Before lightweight tunnels existed, it really didn't make sense to
> create a tunnel that was not fully specified, such as without a
> destination IP address - the resulting packets would go nowhere.
> However, with lightweight tunnels, the opposite is true - it doesn't
> make sense to require this information when it will be provided later
> on by the route. This loosens the requirements for this information.
> 
> An alternative would be to allow the relaxed version only when
> COLLECT_METADATA is enabled. However, since there are several
> variations on this theme (such as NBMA tunnels in GRE), just dropping
> the restrictions seems the most consistent across tunnels and with
> the existing configuration.
> 
> CC: John Linville <linville@tuxdriver.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied, thanks Jesse.
