From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4vf: Fix sparse warnings
Date: Sun, 29 Mar 2015 13:31:28 -0700 (PDT)
Message-ID: <20150329.133128.283263048689172333.davem@davemloft.net>
References: <1427434278-3582-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59581 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752809AbbC2UWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 16:22:45 -0400
In-Reply-To: <1427434278-3582-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Fri, 27 Mar 2015 11:01:18 +0530

> Fixes sparse warnings introduced in commit e85c9a7abfa407ed ("cxgb4/cxgb4vf: Add
> code to calculate T5 BAR2 Offsets for SGE Queue Registers") and
> df64e4d38c904dd3 ("cxgb4/cxgb4vf: Use new interfaces to calculate BAR2 SGE Queue
> Register addresses") and few old ones
> 
> sparse warnings:
>>> drivers/net/ethernet/chelsio/cxgb4vf/sge.c:1006:48: sparse: cast removes
>>> address space of expression
>>> drivers/net/ethernet/chelsio/cxgb4vf/sge.c:1006:48: sparse: incorrect type in
>>> initializer (different address space)
>>> drivers/net/ethernet/chelsio/cxgb4vf/sge.c:1020:40: sparse: incorrect type in
>>> argument 1 (different base types)
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
