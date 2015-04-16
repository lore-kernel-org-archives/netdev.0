From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] fou: Fix missing unlock on error in fou_nl_dump()
Date: Thu, 16 Apr 2015 12:11:39 -0400 (EDT)
Message-ID: <20150416.121139.1274893629327012249.davem@davemloft.net>
References: <1429186479-20265-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, xiyou.wangcong@gmail.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613AbbDPQLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 12:11:41 -0400
In-Reply-To: <1429186479-20265-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: weiyj_lk@163.com
Date: Thu, 16 Apr 2015 20:14:39 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Add the missing unlock before return from function fou_nl_dump()
> in the error handling case.
> 
> Fixes: 7a6c8c34e5b7 (fou: implement FOU_CMD_GET)
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Your patch adds a warning because you fail to remove the 'done'
label which is no longer used.

Cong Wang already submitted a patch which does remove the 'done'
field properly, so I will apply his version.
