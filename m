From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] cxgb4: Fix race condition in cleanup
Date: Thu, 21 Aug 2014 21:45:47 -0700 (PDT)
Message-ID: <20140821.214547.1331125403351758274.davem@davemloft.net>
References: <1408567446-6598-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com, leedom@chelsio.com,
	svemuri@chelsio.com, nhorman@redhat.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46308 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbaHVEps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 00:45:48 -0400
In-Reply-To: <1408567446-6598-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Wed, 20 Aug 2014 13:44:06 -0700

> There is a possible race condition when we unregister the PCI Driver and then
> flush/destroy the global "workq". This could lead to situations where there
> are tasks on the Work Queue with references to now deleted adapter data
> structures. Instead, have per-adapter Work Queues which were instantiated and
> torn down in init_one() and remove_one(), respectively.
> 
> v2: Remove unnecessary call to flush_workqueue() before destroy_workqueue()
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>
> Signed-off-by: Casey Leedom <leedom@chelsio.com>

Applied thanks.
