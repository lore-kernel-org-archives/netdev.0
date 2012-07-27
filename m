From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "openvswitch: potential NULL deref in sample()"
Date: Fri, 27 Jul 2012 13:47:56 -0700 (PDT)
Message-ID: <20120727.134756.54447493810134077.davem@davemloft.net>
References: <1343420380-23119-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	dan.carpenter@oracle.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36730 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547Ab2G0Ur5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 16:47:57 -0400
In-Reply-To: <1343420380-23119-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Fri, 27 Jul 2012 13:19:40 -0700

> This reverts commit 5b3e7e6cb5771bedda51cdb6f715d1da8cd9e644.
> 
> The problem that the original commit was attempting to fix can
> never happen in practice because validation is done one a per-flow
> basis rather than a per-packet basis.  Adding additional checks at
> runtime is unnecessary and inconsistent with the rest of the code.
> 
> CC: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied.
