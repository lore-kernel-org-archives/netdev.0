From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: mcast: give fast leave precedence over
 multicast router and querier
Date: Wed, 29 Jul 2015 14:57:40 -0700 (PDT)
Message-ID: <20150729.145740.1642510215945079225.davem@davemloft.net>
References: <1438079308-25040-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	herbert@gondor.apana.org.au, stephen@networkplumber.org,
	sashok@cumulusnetworks.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753341AbbG2V5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 17:57:41 -0400
In-Reply-To: <1438079308-25040-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Tue, 28 Jul 2015 03:28:27 -0700

> From: Satish Ashok <sashok@cumulusnetworks.com>
> 
> When fast leave is configured on a bridge port and an IGMP leave is
> received for a group, the group is not deleted immediately if there is
> a router detected or if multicast querier is configured.
> Ideally the group should be deleted immediately when fast leave is
> configured.
> 
> Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>

Applied, thanks.
