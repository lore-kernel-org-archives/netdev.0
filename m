From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/cxgb4: Fix referencing freed adapter
Date: Fri, 24 Jan 2014 16:00:50 -0800 (PST)
Message-ID: <20140124.160050.870784460494181105.davem@davemloft.net>
References: <1390554723-15285-1-git-send-email-shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shangw@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40778 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807AbaAYAAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jan 2014 19:00:50 -0500
In-Reply-To: <1390554723-15285-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan <shangw@linux.vnet.ibm.com>
Date: Fri, 24 Jan 2014 17:12:03 +0800

> The adapter is freed before we check its flags. It was caused
> by commit 144be3d ("net/cxgb4: Avoid disabling PCI device for
> towice"). The problem was reported by Intel's "0-day" tool.
> 
> The patch fixes it to avoid reverting commit 144be3d.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>

Applied, thanks.
