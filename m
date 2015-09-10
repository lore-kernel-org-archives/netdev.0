From: David Miller <davem@davemloft.net>
Subject: Re: IFLA_INET6_[ICMP6]STATS
Date: Thu, 10 Sep 2015 10:13:03 -0700 (PDT)
Message-ID: <20150910.101303.1945782677465930122.davem@davemloft.net>
References: <20150909214528.GE20544@oracle.com>
	<55F1A53E.1010908@cumulusnetworks.com>
	<20150910154819.GL20544@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	raghavendra.kt@linux.vnet.ibm.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41141 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754085AbbIJRNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 13:13:04 -0400
In-Reply-To: <20150910154819.GL20544@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu, 10 Sep 2015 11:48:19 -0400

> On (09/10/15 08:43), roopa wrote:
>> If you decide to use a flag, there is IFLA_EXT_MASK which is used to
>> specify such filters from userspace today.
>> 
>> /* New extended info filters for IFLA_EXT_MASK */
>> #define RTEXT_FILTER_VF         (1 << 0)
>> #define RTEXT_FILTER_BRVLAN     (1 << 1)
>> #define RTEXT_FILTER_BRVLAN_COMPRESSED  (1 << 2)
> 
> I was actually going to use a NLM_F* flag, which is what
> I thought Dave as suggesting (seems a bit simpler
> than IFLA_EXT_MASK). 

I don't think using such a generic netlink flag works best, the
IFLA_EXT_MASK is definitely more suitable.
