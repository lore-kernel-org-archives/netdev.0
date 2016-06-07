From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/15] net/smc: Shared Memory Communications -
 RDMA
Date: Tue, 07 Jun 2016 15:07:25 -0700 (PDT)
Message-ID: <20160607.150725.893789208195156330.davem@davemloft.net>
References: <201606031527.u53FQ9dR045418@mx0a-001b2d01.pphosted.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58437 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755371AbcFGWH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 18:07:27 -0400
In-Reply-To: <201606031527.u53FQ9dR045418@mx0a-001b2d01.pphosted.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In case my previous reply wasn't clear enough, I require that you provide
a more accurate description of what the implications of this feature are.

Namely, that important _CORE_ networking features are completely bypassed
and unusable when SMC applies to a connection.

Specifically, all packet shaping, filtering, traffic inspection, and
flow management facilitites in the kernel will not be able to see nor
act upon the data flow of these TCP connections once established.

It is always important, and in my opinion required, to list the
negative aspects of your change and not just the "wow, amazing"
positive aspects.

Thanks.
