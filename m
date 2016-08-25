From: David Miller <davem@redhat.com>
Subject: Re: [PATCH -next] tipc: fix the error handling in tipc_udp_enable()
Date: Thu, 25 Aug 2016 16:33:04 -0700 (PDT)
Message-ID: <20160825.163304.39021884330906317.davem@redhat.com>
References: <1472045539-19923-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
        weiyongjun1@huawei.com, netdev@vger.kernel.org,
        tipc-discussion@lists.sourceforge.net
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59774 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932973AbcHYXnn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 19:43:43 -0400
In-Reply-To: <1472045539-19923-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 24 Aug 2016 13:32:19 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fix to return a negative error code in enable_mcast() error handling
> case, and release udp socket when necessary.
> 
> Fixes: d0f91938bede ("tipc: add ip/udp media type")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Since this bug exists in mainline I applied this patch to 'net'.

Thanks.
