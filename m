From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/15] net/smc: Shared Memory Communications -
 RDMA
Date: Mon, 06 Jun 2016 15:17:40 -0700 (PDT)
Message-ID: <20160606.151740.2048296086973073274.davem@davemloft.net>
References: <201606031527.u53FQ9dR045418@mx0a-001b2d01.pphosted.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47365 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574AbcFFWRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 18:17:42 -0400
In-Reply-To: <201606031527.u53FQ9dR045418@mx0a-001b2d01.pphosted.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Fri,  3 Jun 2016 17:26:59 +0200

> It is transparent to most existing TCP connection load balancers
> that are commonly used in the enterprise data center environment for
> multi-tier application workloads.

I think a better word would be "bypass".  And likewise the data stream
bypasses our packet scheduler, netfilter, classifiers, and just about
every other interesting facility in the kernel.
