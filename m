From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mpls: fix possible use after free of device
Date: Sun, 07 Jun 2015 19:37:43 -0700 (PDT)
Message-ID: <20150607.193743.1723043986420490845.davem@davemloft.net>
References: <1433526885-18861-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	roopa@cumulusnetworks.com
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbbFHCho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 22:37:44 -0400
In-Reply-To: <1433526885-18861-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>
Date: Fri, 5 Jun 2015 18:54:45 +0100

> The mpls device is used in an RCU read context without a lock being
> held. As the memory is freed without waiting for the RCU grace period
> to elapse, the freed memory could still be in use.
> 
> Address this by using kfree_rcu to free the memory for the mpls device
> after the RCU grace period has elapsed.
> 
> Fixes: 03c57747a702 ("mpls: Per-device MPLS state")
> Signed-off-by: Robert Shearman <rshearma@brocade.com>

Applied, thanks.
