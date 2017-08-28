From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 2/3] net/sched: Change cls_flower to use IDR
Date: Mon, 28 Aug 2017 17:55:44 -0400
Message-ID: <a562fbec-797f-1cb2-8af5-cce36126aa23@mojatatu.com>
References: <1503902477-39829-1-git-send-email-chrism@mellanox.com>
 <1503902477-39829-3-git-send-email-chrism@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jiri@resnulli.us, davem@davemloft.net,
        mawilcox@microsoft.com
To: Chris Mi <chrism@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35125 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751208AbdH1Vzq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 17:55:46 -0400
Received: by mail-io0-f194.google.com with SMTP id c18so1587305ioj.2
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 14:55:46 -0700 (PDT)
In-Reply-To: <1503902477-39829-3-git-send-email-chrism@mellanox.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-08-28 02:41 AM, Chris Mi wrote:
> Currently, all filters with the same priority are linked in a doubly
> linked list. Every filter should have a unique handle. To make the
> handle unique, we need to iterate the list every time to see if the
> handle exists or not when inserting a new filter. It is time-consuming.
> For example, it takes about 5m3.169s to insert 64K rules.
> 
> This patch changes cls_flower to use IDR. With this patch, it
> takes about 0m1.127s to insert 64K rules. The improvement is huge.
> 
> But please note that in this testing, all filters share the same action.
> If every filter has a unique action, that is another bottleneck.
> Follow-up patch in this patchset addresses that.
> 
> Signed-off-by: Chris Mi <chrism@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

As Cong asked last time - any plans to add to other classifiers?

cheers,
jamal
