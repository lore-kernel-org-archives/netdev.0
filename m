From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] drivers/net: dsa/mv88e6xxx.c files need
 linux/module.h
Date: Tue, 24 Jan 2012 15:45:02 -0500 (EST)
Message-ID: <20120124.154502.1206016250272962962.davem@davemloft.net>
References: <1327437700-8204-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41778 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754741Ab2AXUpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 15:45:04 -0500
In-Reply-To: <1327437700-8204-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 24 Jan 2012 15:41:40 -0500

> An implicit instance of module.h leaked back into existence
> and was masking the fact that these drivers weren't calling
> out the include for itself.  Fix the drivers before we remove
> the implicit include path via net/netprio_cgroup.h file.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks.
