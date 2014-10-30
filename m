From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4 : Fix missing initialization of win0_lock
Date: Thu, 30 Oct 2014 16:52:44 -0400 (EDT)
Message-ID: <20141030.165244.106112041553973493.davem@davemloft.net>
References: <1414630443-6412-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com, leedom@chelsio.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59288 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933938AbaJ3Uwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 16:52:46 -0400
In-Reply-To: <1414630443-6412-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Wed, 29 Oct 2014 17:54:03 -0700

> win0_lock was being used un-initialized, resulting in warning traces
> being seen when lock debugging is enabled (and just wrong)
> 
> Fixes : fc5ab0209650 ('cxgb4: Replaced the backdoor mechanism to access the HW
>  memory with PCIe Window method')
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>
> Signed-off-by: Casey Leedom <leedom@chelsio.com>

Applied and queued up for -stable, thanks.
