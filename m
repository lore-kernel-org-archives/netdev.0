From: David Miller <davem@davemloft.net>
Subject: Re: IFLA_INET6_[ICMP6]STATS
Date: Wed, 09 Sep 2015 14:43:08 -0700 (PDT)
Message-ID: <20150909.144308.360246374222280540.davem@davemloft.net>
References: <20150909213444.GD20544@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghavendra.kt@linux.vnet.ibm.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35192 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754545AbbIIVnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 17:43:10 -0400
In-Reply-To: <20150909213444.GD20544@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed, 9 Sep 2015 17:34:44 -0400

> So the question is- who uses IFLA_INET6_STATS/IFLA_INET6_ICMP6STATS?
> Is this intended for some ND/ripngd etc daemon?  Doesnt seem to 
> be documented in rtnetlink(7), and couldnt find any users in glibc,
> and google did not find any usage. 

It doesn't really matter who uses it, it's there forever and we
therefore can't remove it.

But what we could do is add a flag in the netlink request which
elides the stats.  GLIBC et al. could then start setting the flag.
