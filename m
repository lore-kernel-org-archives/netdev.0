From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rtnetlink: fix frame size warning in
 rtnl_fill_ifinfo
Date: Mon, 16 Nov 2015 15:38:37 -0500 (EST)
Message-ID: <20151116.153837.635003227845494331.davem@davemloft.net>
References: <1447671903-17975-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41149 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752229AbbKPUij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 15:38:39 -0500
In-Reply-To: <1447671903-17975-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 16 Nov 2015 12:05:03 +0100

> By declaring the huge stack allocations as static. We can do so
> because we hold rtnl.

Look across the tree, this is an idiom copied all over the place.
If putting a rtnl_link_stats64 object on the stack is truly a
problem, we have a lot of spots to fix.

I do not think, therefore, that this solution is tenable, we
need something that handles all cases properly.
