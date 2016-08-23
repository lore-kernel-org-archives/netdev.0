From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 01/15] net: sched: cleanup qdisc_run and
 __qdisc_run semantics
Date: Tue, 23 Aug 2016 13:38:09 -0700
Message-ID: <1471984689.14381.38.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
         <20160823202256.14368.76284.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, davem@davemloft.net, brouer@redhat.com,
        xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36676 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755622AbcHWUiL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 16:38:11 -0400
Received: by mail-pf0-f193.google.com with SMTP id y134so8805898pfg.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 13:38:11 -0700 (PDT)
In-Reply-To: <20160823202256.14368.76284.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-08-23 at 13:22 -0700, John Fastabend wrote:
> Currently __qdisc_run calls qdisc_run_end() but does not call
> qdisc_run_begin(). This makes it hard to track pairs of
> qdisc_run_{begin,end} across function calls.
> 
> To simplify reading these code paths and simpler code this
> patch moves begin/end calls into qdisc_run().
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
Acked-by: Eric Dumazet <edumazet@google.com>
