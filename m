From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: compute a more reasonable default ip6_rt_max_size
Date: Fri, 25 May 2012 16:26:42 -0400 (EDT)
Message-ID: <20120525.162642.1462528409650391977.davem@davemloft.net>
References: <1337976934-18065-1-git-send-email-asharma@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: asharma@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52579 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933230Ab2EYU0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 16:26:46 -0400
In-Reply-To: <1337976934-18065-1-git-send-email-asharma@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arun Sharma <asharma@fb.com>
Date: Fri, 25 May 2012 13:15:34 -0700

> +	/* Compute a reasonable default based on what we do for ipv4
> +	 * total size = 1/16th of total RAM
> +	 * No more than 512k entries unless overridden on kernel cmdline */

Please format this comment correctly:

	/* Compute a reasonable default based on what we do for ipv4
	 * total size = 1/16th of total RAM
	 * No more than 512k entries unless overridden on kernel cmdline
	 */
