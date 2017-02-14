From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [patch net-next 2/6] sched: move tcf_proto_destroy and
 tcf_destroy_chain helpers into cls_api
Date: Tue, 14 Feb 2017 18:25:01 +0100
Message-ID: <20170214172501.GA4182@bistromath.localdomain>
References: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
 <1486647540-14656-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59666 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754956AbdBNRZP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Feb 2017 12:25:15 -0500
Content-Disposition: inline
In-Reply-To: <1486647540-14656-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

2017-02-09, 14:38:56 +0100, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Creation is done in this file, move destruction to be at the same place.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/net/pkt_cls.h     |  2 ++
>  include/net/sch_generic.h |  2 --
>  net/sched/cls_api.c       | 21 +++++++++++++++++++++
>  net/sched/sch_api.c       | 22 ----------------------
>  net/sched/sch_atm.c       |  1 +
>  net/sched/sch_cbq.c       |  1 +
>  net/sched/sch_choke.c     |  1 +
>  net/sched/sch_dsmark.c    |  1 +
>  net/sched/sch_fq_codel.c  |  1 +
>  net/sched/sch_htb.c       |  1 +
>  net/sched/sch_ingress.c   |  1 +
>  net/sched/sch_multiq.c    |  2 +-
>  net/sched/sch_prio.c      |  2 +-
>  net/sched/sch_sfb.c       |  1 +
>  net/sched/sch_sfq.c       |  1 +
>  15 files changed, 34 insertions(+), 26 deletions(-)

This broke the build for !NET_CLS:

net/built-in.o: In function `fq_codel_destroy':
/home/sab/linux/net-next/net/sched/sch_fq_codel.c:468: undefined reference to `tcf_destroy_chain'


-- 
Sabrina
