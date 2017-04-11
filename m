From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] devlink: fix return value check in
 devlink_dpipe_header_put()
Date: Tue, 11 Apr 2017 08:39:03 +0200
Message-ID: <20170411063903.GA2046@nanopsycho>
References: <20170410131106.27683-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>,
        Arkadi Sharshevsky <arkadis@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33196 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753508AbdDKGjG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 02:39:06 -0400
Received: by mail-wr0-f193.google.com with SMTP id l28so6949923wre.0
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 23:39:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170410131106.27683-1-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Apr 10, 2017 at 03:11:06PM CEST, weiyj.lk@gmail.com wrote:
>From: Wei Yongjun <weiyongjun1@huawei.com>
>
>Fix the retrn value check which testing the wrong variable

         ^^^^^ typo

Otherwise,
Acked-by: Jiri Pirko <jiri@mellanox.com>


>in devlink_dpipe_header_put().
>
>Fixes: 1555d204e743 ("devlink: Support for pipeline debug (dpipe)")
>Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
>---
> net/core/devlink.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/net/core/devlink.c b/net/core/devlink.c
>index 24b7660..0afac58 100644
>--- a/net/core/devlink.c
>+++ b/net/core/devlink.c
>@@ -2031,7 +2031,7 @@ static int devlink_dpipe_header_put(struct sk_buff *skb,
> 	int err;
> 
> 	header_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_HEADER);
>-	if (!header)
>+	if (!header_attr)
> 		return -EMSGSIZE;
> 
> 	if (nla_put_string(skb, DEVLINK_ATTR_DPIPE_HEADER_NAME, header->name) ||
>
