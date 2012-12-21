From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: call br_netpoll_disable in br_add_if
Date: Fri, 21 Dec 2012 13:17:15 -0800 (PST)
Message-ID: <20121221.131715.213728313109012871.davem@davemloft.net>
References: <1355996503-19318-1-git-send-email-gaofeng@cn.fujitsu.com>
	<1355999613.25310.11.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gaofeng@cn.fujitsu.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44613 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868Ab2LUVRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 16:17:16 -0500
In-Reply-To: <1355999613.25310.11.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Thu, 20 Dec 2012 18:33:33 +0800

> On Thu, 2012-12-20 at 17:41 +0800, Gao feng wrote:
>> When netdev_set_master faild in br_add_if, we should
>> call br_netpoll_disable to do some cleanup jobs,such
>> as free the memory of struct netpoll which allocated
>> in br_netpoll_enable.
>> 
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> 
> Looks good!
> 
> Acked-by: Cong Wang <amwang@redhat.com>

Applied.
