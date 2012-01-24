From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netprio_cgroup.h: dont include module.h from other
 includes
Date: Tue, 24 Jan 2012 16:42:40 -0500 (EST)
Message-ID: <20120124.164240.1834989778592427907.davem@davemloft.net>
References: <1327440799-1057-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org, jdb@comx.dk,
	eric.dumazet@gmail.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060Ab2AXVnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 16:43:52 -0500
In-Reply-To: <1327440799-1057-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 24 Jan 2012 16:33:19 -0500

> A considerable effort was invested in wiping out module.h
> from being present in all the other standard includes.  This
> one leaked back in, but once again isn't strictly necessary,
> so remove it.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> 
> ---
> 
> [x86-64 modconfig, yesconfig and ppc64 defconfig all build OK]

Applied, thanks Paul.
