From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ibmvnic: fix to use list_for_each_safe() when
 delete items
Date: Sat, 25 Jun 2016 12:02:41 -0400 (EDT)
Message-ID: <20160625.120241.1521209512436530662.davem@davemloft.net>
References: <576810C2.6080208@linux.vnet.ibm.com>
	<576964CF.3040804@linux.vnet.ibm.com>
	<2db3a1f8-cafd-8fde-6223-2b2e3787d615@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tlfalcon@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
	netdev@vger.kernel.org, yongjun_wei@trendmicro.com.cn,
	linuxppc-dev@lists.ozlabs.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54439 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541AbcFYQCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 12:02:45 -0400
In-Reply-To: <2db3a1f8-cafd-8fde-6223-2b2e3787d615@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj_lk@163.com>
Date: Wed, 22 Jun 2016 10:51:46 +0800

> Since we will remove items off the list using list_del() we need
> to use a safe version of the list_for_each() macro aptly named
> list_for_each_safe().
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Your email client has corrupted the spacing in this patch, making
it unusable.
