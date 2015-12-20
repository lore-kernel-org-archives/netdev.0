From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmveth: consolidate kmalloc of array, memset 0 to
 kcalloc
Date: Sun, 20 Dec 2015 13:00:40 -0500 (EST)
Message-ID: <20151220.130040.2258523353905721130.davem@davemloft.net>
References: <1450620378-8342-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tlfalcon@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hofrat@osadl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbbLTSAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Dec 2015 13:00:42 -0500
In-Reply-To: <1450620378-8342-1-git-send-email-hofrat@osadl.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicholas Mc Guire <hofrat@osadl.org>
Date: Sun, 20 Dec 2015 15:06:18 +0100

> This is an API consolidation only. The use of kmalloc + memset to 0
> is equivalent to kcalloc in this case as it is allocating an array
> of elements.
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Applied, thanks.
