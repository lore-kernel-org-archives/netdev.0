From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mpls_iptunnel: fix sparse warn: remove
 incorrect rcu_dereference
Date: Wed, 22 Jul 2015 10:50:34 -0700 (PDT)
Message-ID: <20150722.105034.281768363712121509.davem@davemloft.net>
References: <1437544140-38090-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43477 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757215AbbGVRue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 13:50:34 -0400
In-Reply-To: <1437544140-38090-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Tue, 21 Jul 2015 22:49:00 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> fix for:
> net/mpls/mpls_iptunnel.c:73:19: sparse: incompatible types in comparison
> expression (different address spaces)
> 
> remove incorrect rcu_dereference possibly left over from
> earlier revisions of the code.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied.
