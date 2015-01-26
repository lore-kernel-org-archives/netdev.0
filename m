From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: Fix __ip6_route_redirect
Date: Sun, 25 Jan 2015 22:10:22 -0800 (PST)
Message-ID: <20150125.221022.2239123042100940879.davem@davemloft.net>
References: <1421810162-2910767-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39358 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbbAZGK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 01:10:26 -0500
In-Reply-To: <1421810162-2910767-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Tue, 20 Jan 2015 19:16:02 -0800

> In my last commit (a3c00e4: ipv6: Remove BACKTRACK macro), the changes in
> __ip6_route_redirect is incorrect.  The following case is missed:
> 1. The for loop tries to find a valid gateway rt. If it fails to find
>    one, rt will be NULL.
> 2. When rt is NULL, it is set to the ip6_null_entry.
> 3. The newly added 'else if', from a3c00e4, will stop the backtrack from
>    happening.
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Applied and queued up for -stable, thanks!
