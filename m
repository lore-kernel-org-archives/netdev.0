From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/10] Mellanox driver updates Oct 31 2013
Date: Sat, 02 Nov 2013 02:20:03 -0400 (EDT)
Message-ID: <20131102.022003.626036008640723018.davem@davemloft.net>
References: <1383222569-10930-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, roland@kernel.org,
	jackm@dev.mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34060 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205Ab3KBGUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 02:20:05 -0400
In-Reply-To: <1383222569-10930-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 31 Oct 2013 14:29:19 +0200

> This patch set from Jack Morgenstein does the following:
> 
> 1. Fix MAC/VLAN SRIOV implementation, and add wrapper functions for VLAN allocation
>    and de-allocation (patches 1-6).
> 
> 2. Implements resource quotas when running under SRIOV (patches 7-10).
>    Patch 7 is a small bug fix, and patches 8-10 implement the quotas.
> 
> Quotas are implemented per resource type for VFs and the PF, to prevent
> any entity from simply grabbing all the resources for itself and leaving
> the other entities unable to obtain such resources.
> 
> The series is against net-next commit ba48650 "ipv6: remove the unnecessary statement in find_match()"
> 
> Patch #1 is bug fix which needs to go into -stable of kernels >= 3.10 

You cannot submit via net-next a bug fix that you want to go to -stable.
I've stated this a thousand times.

You MUST submit the bug fix for "net", not "net-next".

I'm tossing this entire series, submit your changes correctly.

Thank you.
