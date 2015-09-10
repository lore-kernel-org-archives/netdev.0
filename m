From: David Miller <davem@davemloft.net>
Subject: Re: IFLA_INET6_[ICMP6]STATS
Date: Thu, 10 Sep 2015 10:20:35 -0700 (PDT)
Message-ID: <20150910.102035.936401981874229191.davem@davemloft.net>
References: <20150910154819.GL20544@oracle.com>
	<20150910.101303.1945782677465930122.davem@davemloft.net>
	<20150910171630.GP20544@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	raghavendra.kt@linux.vnet.ibm.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41223 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217AbbIJRUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 13:20:36 -0400
In-Reply-To: <20150910171630.GP20544@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu, 10 Sep 2015 13:16:30 -0400

> On (09/10/15 10:13), David Miller wrote:
>> I don't think using such a generic netlink flag works best, the
>> IFLA_EXT_MASK is definitely more suitable.
> 
> Ok, though this more of a IFLA_TRUNCATE_MASK than a IFLA_EXT_MASK.

IFLA_EXT_MASK is precisely for filtering out objects and attributes
from a netlink dump or reply, there is no reason to make a new
attribute with a different name for this.
