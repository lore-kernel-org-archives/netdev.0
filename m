From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6 PKT_SCHED]: Fix rcu_assign_pointer fallout, use it
 in the right place
Date: Fri, 5 Nov 2004 16:46:55 -0800
Message-ID: <20041105164655.5d5639b8.davem@davemloft.net>
References: <418BF48A.5060707@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <418BF48A.5060707@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 05 Nov 2004 22:45:46 +0100
Patrick McHardy <kaber@trash.net> wrote:

> The patch "RCU: use rcu_assign_pointer()" 
> http://linux.bkbits.net:8080/linux-2.6/diffs/net/sched/sch_api.c@1.39?nav=index.html|src/net/|src/net|src/net/sched|related/net/sched/sch_api.c|cset@1.2287
> changed a list_add_tail to list_add_tail_rcu in qdisc_create. It's
> dev->qdisc not dev->qdisc_list that is protected by RCU, this patch
> reverts that change. It also removes a misleading comment and replaces
> the smp_wmb in qdisc_create_dflt by rcu_assign_pointer in dev_activate
> to document more clearly what is protected.

Good catch Patrick, patch applied.

Thanks a lot.
