From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix some compiler warning in
 net/core/neighbour.c
Date: Wed, 05 Dec 2012 21:51:36 -0500 (EST)
Message-ID: <20121205.215136.40885654322570923.davem@davemloft.net>
References: <1354759444-4937-1-git-send-email-amwang@redhat.com>
	<50C00544.7060307@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org, davidshan@tencent.com
To: shanwei88@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932226Ab2LFCvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 21:51:37 -0500
In-Reply-To: <50C00544.7060307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei88@gmail.com>
Date: Thu, 06 Dec 2012 10:39:00 +0800

> Cong Wang said, at 2012/12/6 10:04:
>> From: Cong Wang <amwang@redhat.com>
>> 
>> net/core/neighbour.c:65:12: warning: 'zero' defined but not used [-Wunused-variable]
>> net/core/neighbour.c:66:12: warning: 'unres_qlen_max' defined but not used [-Wunused-variable]
>> 
>> These variables are only used when CONFIG_SYSCTL is defined,
>> so move them under #ifdef CONFIG_SYSCTL.
>> 
>> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
>> Cc: Shan Wei <davidshan@tencent.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> Rapid response~~~ :-)
> Same patch in my tree，and i see your patch when prepare to submit it.
> 
> Acked-by: Shan Wei <davidshan@tencent.com>

Applied.
