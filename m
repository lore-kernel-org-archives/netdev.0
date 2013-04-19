From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] bridge: Add fdb dst check during fdb update
Date: Fri, 19 Apr 2013 16:51:24 -0400 (EDT)
Message-ID: <20130419.165124.1032752136933355380.davem@davemloft.net>
References: <1365968593-28725-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	nolan@cumulusnetworks.com, shm@cumulusnetworks.com,
	wkok@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47860 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754071Ab3DSUv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 16:51:26 -0400
In-Reply-To: <1365968593-28725-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa@cumulusnetworks.com
Date: Sun, 14 Apr 2013 12:43:13 -0700

> From: roopa <roopa@cumulusnetworks.com>
> 
> Current bridge fdb update code does not seem to update the port
> during fdb update. This patch adds a check for fdb dst (port)
> change during fdb update. Also rearranges the call to
> fdb_notify to send only one notification for create and update.
> 
> Changelog:
> v2 - Change notify flag to bool
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

This needs review and is just rotting in my patchwork backlog.

Please someone with bridge knowledge take a look at this patch.

Thanks.
