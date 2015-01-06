From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined
Date: Mon, 05 Jan 2015 22:52:41 -0500 (EST)
Message-ID: <20150105.225241.2023994227710574197.davem@davemloft.net>
References: <54AAC9F1.9060409@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ray.kinsella@intel.com
To: hubert.sokolowski@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37350 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbbAFDwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 22:52:44 -0500
In-Reply-To: <54AAC9F1.9060409@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hubert Sokolowski <hubert.sokolowski@intel.com>
Date: Mon, 05 Jan 2015 17:29:21 +0000

> Add checking whether the call to ndo_dflt_fdb_dump is needed.
> It is not expected to call ndo_dflt_fdb_dump unconditionally
> by some drivers (i.e. qlcnic or macvlan) that defines
> own ndo_fdb_dump. Other drivers define own ndo_fdb_dump
> and don't want ndo_dflt_fdb_dump to be called at all.
> At the same time it is desirable to call the default dump
> function on a bridge device.
> Fix attributes that are passed to dev->netdev_ops->ndo_fdb_dump.
> Add extra checking in br_fdb_dump to avoid duplicate entries
> as now filter_dev can be NULL.
> 
> Following tests for filtering have been performed before
> the change and after the patch was applied to make sure
> they are the same and it doesn't break the filtering algorithm.
 ...
> Signed-off-by: Hubert Sokolowski <hubert.sokolowski@intel.com>

Applied, thank you.
