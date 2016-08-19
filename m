From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 11/13] net: sched: pfifo_fast use alf_queue
Date: Fri, 19 Aug 2016 08:44:49 -0700
Message-ID: <57B72971.4020000@gmail.com>
References: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
 <20160817193810.27032.27544.stgit@john-Precision-Tower-5810>
 <20160819121303.50963024@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
        alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        davem@davemloft.net, "Michael S. Tsirkin" <mst@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34669 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755614AbcHSPpE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 11:45:04 -0400
Received: by mail-pf0-f196.google.com with SMTP id g202so1651807pfb.1
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 08:45:03 -0700 (PDT)
In-Reply-To: <20160819121303.50963024@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-19 03:13 AM, Jesper Dangaard Brouer wrote:
> On Wed, 17 Aug 2016 12:38:10 -0700
> John Fastabend <john.fastabend@gmail.com> wrote:
> 
>> This converts the pfifo_fast qdisc to use the alf_queue enqueue and
>                                                 ^^^^^^^^^
>> dequeue routines then sets the NOLOCK bit.
>>
>> This also removes the logic used to pick the next band to dequeue from
>> and instead just checks each alf_queue for packets from top priority
>                                ^^^^^^^^^
>> to lowest. This might need to be a bit more clever but seems to work
>> for now.
> 
> You need to fix the description, as you are no longer using my
> alf_queue implementation but instead are using the skb_array/ptr_ring
> queue (by MST).
> 

Yep I forgot to change this even though iirc you may have had the same
comment in the last rev. Thanks! I'll get it fixed up this time.

.John
