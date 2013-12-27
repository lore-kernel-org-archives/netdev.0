From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH net-next RESEND v3] tipc: make the code look more readable
Date: Fri, 27 Dec 2013 12:21:04 +0800
Message-ID: <52BD0030.10107@huawei.com>
References: <1387263827-20876-3-git-send-email-wangweidong1@huawei.com>	<52BCDBA4.9050607@huawei.com>	<52BCE163.2060706@huawei.com> <20131226.230438.1160354521580370981.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <jon.maloy@ericsson.com>, <allan.stephens@windriver.com>,
	<David.Laight@ACULAB.COM>, <netdev@vger.kernel.org>,
	<sergei.shtylyov@cogentembedded.com>, <ying.xue@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:25557 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639Ab3L0EV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 23:21:28 -0500
In-Reply-To: <20131226.230438.1160354521580370981.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/27 12:04, David Miller wrote:
> 
> You need to resubmit patch #1 along with this one, not just this
> one by itself.
> 
> Thanks.
> 
> 
As Ying pointed out that the patch #1 ("tipc: make the code look more better")
does not provide any value. something like below:

Actually the original logic seems better understandable for us because
it immediately lets us know how to do if "tp_ptr->connected" is true.
Instead the patch has a little negative effect on performance because
"tp_ptr->connected" is true in most time.

So I drop the patch #1. Now only this patch.

Regards,
Wang
