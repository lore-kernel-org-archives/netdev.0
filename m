From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 2/3] net/sched: Change cls_flower to use IDR
Date: Wed, 30 Aug 2017 08:09:14 -0400
Message-ID: <38cea4fa-1ca2-1055-0595-4febf3c08e27@mojatatu.com>
References: <1504074719-15147-1-git-send-email-chrism@mellanox.com>
 <1504074719-15147-3-git-send-email-chrism@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jiri@resnulli.us, davem@davemloft.net,
        mawilcox@microsoft.com
To: Chris Mi <chrism@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33239 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751282AbdH3MJV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 08:09:21 -0400
Received: by mail-it0-f67.google.com with SMTP id 77so915740itj.0
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 05:09:21 -0700 (PDT)
In-Reply-To: <1504074719-15147-3-git-send-email-chrism@mellanox.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-08-30 02:31 AM, Chris Mi wrote:
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


BTW: I'd already acked this before but you left it out in this
version.

cheers,
jamal
