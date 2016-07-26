From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: ipmr/ip6mr: update lastuse on entry
 change
Date: Tue, 26 Jul 2016 15:19:14 -0700 (PDT)
Message-ID: <20160726.151914.1012145725428146096.davem@davemloft.net>
References: <1469550861-13032-1-git-send-email-nikolay@cumulusnetworks.com>
	<1469552092-16019-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	sharpd@cumulusnetworks.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41892 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251AbcGZWTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 18:19:17 -0400
In-Reply-To: <1469552092-16019-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Tue, 26 Jul 2016 18:54:52 +0200

> Currently lastuse is updated on entry creation and cache hit, but it should
> also be updated on entry change. Since both on add and update the ttl array
> is updated we can simply update the lastuse in ipmr_update_thresholds.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied.
