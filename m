From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tipc: avoid possible deadlock while enable and
 disable bearer
Date: Sun, 11 Aug 2013 21:59:39 -0700 (PDT)
Message-ID: <20130811.215939.1897644088555839854.davem@davemloft.net>
References: <5204B29A.80809@huawei.com>
	<5204B78D.4090509@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dingtianhong@huawei.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org,
	wangweidong1@huawei.com
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47679 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752981Ab3HLE4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 00:56:23 -0400
In-Reply-To: <5204B78D.4090509@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Fri, 9 Aug 2013 17:34:05 +0800

> 
>> The problem is that the tipc_link_delete() will cancel the timer disc_timeout() when
>> the b_ptr->lock is hold, but the disc_timeout() still call b_ptr->lock to finish the
>> work, so the dead lock occurs.
>> 
>> We should unlock the b_ptr->lock when del the disc_timeout().
>> 
>> Remove link_timeout() still met the same problem, the patch:
>> 
>> http://article.gmane.org/gmane.network.tipc.general/4380
>> 
>> fix the problem, so no need to send patch for fix link_timeout() deadlock warming.
>> 
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> Cc: Ying Xue <ying.xue@windriver.com>
> 
> Ack-by: Ying Xue <ying.xue@windriver.com>

The proper syntax is "Acked-by: " not "Ack-by: "

Applied.
