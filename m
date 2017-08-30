From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 3/3] net/sched: Change act_api and act_xxx
 modules to use IDR
Date: Wed, 30 Aug 2017 08:11:10 -0400
Message-ID: <5b54f1c5-688a-5a7d-25bd-05dc9cbecebd@mojatatu.com>
References: <1504074719-15147-1-git-send-email-chrism@mellanox.com>
 <1504074719-15147-4-git-send-email-chrism@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jiri@resnulli.us, davem@davemloft.net,
        mawilcox@microsoft.com
To: Chris Mi <chrism@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35044 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751282AbdH3MLN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 08:11:13 -0400
Received: by mail-it0-f65.google.com with SMTP id b76so912846itb.2
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 05:11:13 -0700 (PDT)
In-Reply-To: <1504074719-15147-4-git-send-email-chrism@mellanox.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-08-30 02:31 AM, Chris Mi wrote:
> Typically, each TC filter has its own action. All the actions of the
> same type are saved in its hash table. But the hash buckets are too
> small that it degrades to a list. And the performance is greatly
> affected. For example, it takes about 0m11.914s to insert 64K rules.
> If we convert the hash table to IDR, it only takes about 0m1.500s.
> The improvement is huge.
> 
> But please note that the test result is based on previous patch that
> cls_flower uses IDR.
> 
> Signed-off-by: Chris Mi <chrism@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Also already acked this before but you left it out in this
version. If you make changes to the patch then you will need
a new ACK.

Dont forget to update selftests please.

cheers,
jamal
