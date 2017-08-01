From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v12 0/4] net sched actions: improve dump
 performance
Date: Tue, 1 Aug 2017 07:05:36 -0400
Message-ID: <f1a1d2ee-fbd6-5b2b-8bf1-b39638483db1@mojatatu.com>
References: <1501435492-28301-1-git-send-email-jhs@emojatatu.com>
 <20170730.192836.370680005861016480.davem@davemloft.net>
 <466dd890-ffae-4cdb-dc97-d173bd390148@mojatatu.com>
 <20170731205419.6710fe11@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        jiri@resnulli.us, xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        horms@verge.net.au, dsahern@gmail.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36828 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751217AbdHALFi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 07:05:38 -0400
Received: by mail-io0-f196.google.com with SMTP id j32so1279378iod.3
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 04:05:38 -0700 (PDT)
In-Reply-To: <20170731205419.6710fe11@xeon-e3>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-07-31 11:54 PM, Stephen Hemminger wrote:
> On Mon, 31 Jul 2017 08:06:42 -0400
> Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> 

[..]
> Please cleanup and resubmit for net-next.
>

Will do.

> The header files have been updated in iproute2 net-next branch.
> 

When does net-next show up? I noticed some changes - example Jiri's
multi-table changes are not in the tree (I believe they were submitted
as part of net-next).

> It is not clear to me that the new code is backward compatiable
> Will new versions of tc work on old kernels and vice/versa?
> 

AFAIK and tested it is.

> 
> Also, no #ifdef's

Those will go away. The intention was to test things which will be
rejected (in case some other app in the future uses this feature).

cheers,
jamal
