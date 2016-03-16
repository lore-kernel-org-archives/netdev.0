From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: consolidate local_bh_disable/enable +
 spin_lock/unlock to _bh variant
Date: Wed, 16 Mar 2016 19:21:09 -0400 (EDT)
Message-ID: <20160316.192109.340706734153471879.davem@davemloft.net>
References: <1457866104-24342-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, wangweidong1@huawei.com,
	nhorman@tuxdriver.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hofrat@osadl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966308AbcCPXVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 19:21:11 -0400
In-Reply-To: <1457866104-24342-1-git-send-email-hofrat@osadl.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicholas Mc Guire <hofrat@osadl.org>
Date: Sun, 13 Mar 2016 11:48:24 +0100

> local_bh_disable() + spin_lock() is equivalent to spin_lock_bh(), same for
> the unlock/enable case, so replace the calls by the appropriate wrappers.
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Applied.
