From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: Fix MC1 memory offset calculation
Date: Wed, 29 Apr 2015 15:50:56 -0400 (EDT)
Message-ID: <20150429.155056.2283090558132454304.davem@davemloft.net>
References: <1430308145-15225-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
	swise@opengridcomputing.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50589 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbbD2Tu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 15:50:58 -0400
In-Reply-To: <1430308145-15225-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed, 29 Apr 2015 17:19:05 +0530

> Commit 6559a7e8296002b4 ("cxgb4: Cleanup macros so they follow the same
> style and look consistent") introduced a regression where reading MC1
> memory in adapters where MC0 isn't present or MC0 size is not equal to MC1
> size caused the adapter to crash due to incorrect computation of memoffset.
> Fix is to read the size of MC0 instead of MC1 for offset calculation
> 
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied and queued up for -stable, thanks.
