From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH 2.4.21][FIX] use mod_timer
Date: Fri, 20 Jun 2003 19:10:50 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0306201907450.27218-100000@excalibur.intercode.com.au>
References: <1056091000.1200.23.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Marcelo Tosatti <marcelo@hera.kernel.org>, <netdev@oss.sgi.com>,
   Jesse Barnes <jbarnes@sgi.com>, Alan Cox <alan@redhat.com>,
   LKML <linux-kernel@vger.kernel.org>, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vinay K Nallamothu <vinay-rc@naturesoft.net>
In-Reply-To: <1056091000.1200.23.camel@lima.royalchallenge.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 20 Jun 2003, Vinay K Nallamothu wrote:

> Hi,
> 
> This patch makes use of mod_timer instead of {del,add}_timer.
> 
> Most of the patches already in -ac series since 2.4.21-rc2 and few of
> the networking fixes in 2.5.69
> 
> The following files are affected:
> 
> arch/ia64/sn/kernel/irq.c
> arch/ia64/sn/kernel/mca.c
> drivers/block/floppy.c
> drivers/net/wan/sdla_chdlc.c
> drivers/net/wan/sdla_fr.c
> drivers/net/wan/sdla_x25.c
> net/core/dst.c
> net/sched/sch_cbq.c
> net/sched/sch_csz.c
> net/sched/sch_htb.c


FYI, the status of the networking patches is:

                     2.5-bk   2.4.21-ac1    2.4-bk
net/core/dst.c        yes        no           no
net/sched/sch_cbq.c   yes       yes           no
net/sched/sch_csz.c   yes       yes           no
net/sched/sch_htb.c   yes       yes           no



- James
-- 
James Morris
<jmorris@intercode.com.au>
