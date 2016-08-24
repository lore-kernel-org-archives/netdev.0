From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 05/15] net: sched: a dflt qdisc may be used
 with per cpu stats
Date: Wed, 24 Aug 2016 12:08:28 -0700
Message-ID: <1472065708.14381.114.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
         <20160823202445.14368.4352.stgit@john-Precision-Tower-5810>
         <1472056898.14381.95.camel@edumazet-glaptop3.roam.corp.google.com>
         <57BDD5AE.8030208@gmail.com>
         <1472059610.14381.103.camel@edumazet-glaptop3.roam.corp.google.com>
         <57BDDE51.2050106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, davem@davemloft.net, brouer@redhat.com,
        xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36565 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753655AbcHXTJt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 15:09:49 -0400
Received: by mail-pa0-f66.google.com with SMTP id ez1so1655557pab.3
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 12:08:30 -0700 (PDT)
In-Reply-To: <57BDDE51.2050106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-08-24 at 10:50 -0700, John Fastabend wrote:
> On 16-08-24 10:26 AM, Eric Dumazet wrote:
> > On Wed, 2016-08-24 at 10:13 -0700, John Fastabend wrote:
> > 
> >>>
> >>
> >> I could fully allocate it in qdisc_alloc() but we don't know if the
> >> qdisc needs per cpu data structures until after the init call
> > 
> > Should not we have a flag to advertise the need of per spu stats on
> > qdisc ?
> > 
> > This is not clear why ->init() can know this, and not its caller.
> > 
> 
> sure we could be a static_flags field in the ops structure. What do
> you think about doing that?

This is what I was suggesting yes.

> 
> We would still need some flags to be set at init though like the bypass
> bit it looks like some qdiscs set that based on user input.
> 
