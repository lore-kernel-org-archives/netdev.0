From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix build failure in xilinx
Date: Tue, 20 Nov 2012 15:52:41 -0500 (EST)
Message-ID: <20121120.155241.2139572423025940885.davem@davemloft.net>
References: <50ABE6B1.7060308@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dannyfeng@tencent.com
To: jeffm@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43956 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737Ab2KTUwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 15:52:43 -0500
In-Reply-To: <50ABE6B1.7060308@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Mahoney <jeffm@suse.com>
Date: Tue, 20 Nov 2012 15:23:13 -0500

> Commit 71c6c837 (drivers/net: fix tasklet misuse issue) introduced a
> build failure in the xilinx driver. axienet_dma_err_handler isn't
> declared before its use in axienet_open.
> 
> This patch provides the prototype before axienet_open.
> 
> Cc: Xiaotian Feng <dannyfeng@tencent.com>
> Signed-off-by: Jeff Mahoney <jeffm@suse.com>

Applied.
