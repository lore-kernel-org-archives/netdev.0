From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: IFLA_INET6_[ICMP6]STATS
Date: Wed, 9 Sep 2015 17:45:28 -0400
Message-ID: <20150909214528.GE20544@oracle.com>
References: <20150909213444.GD20544@oracle.com>
 <20150909.144308.360246374222280540.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghavendra.kt@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30754 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020AbbIIVpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 17:45:32 -0400
Content-Disposition: inline
In-Reply-To: <20150909.144308.360246374222280540.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/09/15 14:43), David Miller wrote:
> 
> But what we could do is add a flag in the netlink request which
> elides the stats.  GLIBC et al. could then start setting the flag.
> 

Yes, interestingly that's what I was experimenting with myself 
(though I was using a setsockopt in my version). I'll send out 
a patch rfc later this week for this.

--Sowmini
