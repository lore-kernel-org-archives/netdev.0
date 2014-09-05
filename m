From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: dual_emac: fix reducing of
 rx descriptor during ifdown
Date: Fri, 05 Sep 2014 14:29:17 -0700 (PDT)
Message-ID: <20140905.142917.1749731214890237469.davem@davemloft.net>
References: <54058C01.3010402@ti.com>
	<20140902.115434.1276391011837651390.davem@davemloft.net>
	<5406C067.5080103@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56279 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278AbaIEV3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 17:29:17 -0400
In-Reply-To: <5406C067.5080103@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Wed, 3 Sep 2014 12:46:55 +0530

> On Wednesday 03 September 2014 12:24 AM, David Miller wrote:
>> Also this doesn't explain why the "status < 0" case applies to this
>> new logic, you have not explained that at all.
>> 
> 
> This scenario is not generated when "status < 0", "status < 0" happens
> when DMA is in tear-down mode, the above scenario happens when
> netif_running(ndev) is false which denotes that netdev is down already.

Your condition was:

	if (status < 0 || !netif_running(ndev))

so this "scenerio" is being handled when status < 0, which is what
I am objecting to.
