From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: IFLA_INET6_[ICMP6]STATS
Date: Thu, 10 Sep 2015 11:48:19 -0400
Message-ID: <20150910154819.GL20544@oracle.com>
References: <20150909213444.GD20544@oracle.com>
 <20150909.144308.360246374222280540.davem@davemloft.net>
 <20150909214528.GE20544@oracle.com>
 <55F1A53E.1010908@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	raghavendra.kt@linux.vnet.ibm.com
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:44304 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574AbbIJPsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 11:48:36 -0400
Content-Disposition: inline
In-Reply-To: <55F1A53E.1010908@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/10/15 08:43), roopa wrote:
> If you decide to use a flag, there is IFLA_EXT_MASK which is used to
> specify such filters from userspace today.
> 
> /* New extended info filters for IFLA_EXT_MASK */
> #define RTEXT_FILTER_VF         (1 << 0)
> #define RTEXT_FILTER_BRVLAN     (1 << 1)
> #define RTEXT_FILTER_BRVLAN_COMPRESSED  (1 << 2)

I was actually going to use a NLM_F* flag, which is what
I thought Dave as suggesting (seems a bit simpler
than IFLA_EXT_MASK). 

--Sowmini
