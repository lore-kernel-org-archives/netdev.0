From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: minor optimization in
 qdisc_qstats_cpu_drop()
Date: Wed, 24 Aug 2016 12:13:53 -0700
Message-ID: <1472066033.14381.116.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472059414.14381.101.camel@edumazet-glaptop3.roam.corp.google.com>
         <57BDE0BC.9040607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33108 "EHLO
        mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753995AbcHXTOM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 15:14:12 -0400
Received: by mail-pa0-f46.google.com with SMTP id ti13so9106542pac.0
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 12:13:54 -0700 (PDT)
In-Reply-To: <57BDE0BC.9040607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-08-24 at 11:00 -0700, John Fastabend wrote:

> Looks good to me. I guess we can also do the same for overlimit qstats.
> 
> Acked-by: John Fastabend <john.r.fastabend@intel.com>

Not sure about overlimit, although I could probably change these :

net/sched/act_bpf.c:85:         qstats_drop_inc(this_cpu_ptr(prog->common.cpu_qstats));
net/sched/act_gact.c:145:               qstats_drop_inc(this_cpu_ptr(gact->common.cpu_qstats));
