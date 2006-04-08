From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.4.32: unresolved symbol unregister_qdisc
Date: Sat, 08 Apr 2006 15:54:30 -0700 (PDT)
Message-ID: <20060408.155430.111013393.davem@davemloft.net>
References: <32947.128.2.140.234.1144536454.squirrel@128.2.140.234>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965046AbWDHWzG@vger.kernel.org>
To: gnychis@cmu.edu
In-Reply-To: <32947.128.2.140.234.1144536454.squirrel@128.2.140.234>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "George P Nychis" <gnychis@cmu.edu>
Date: Sat, 8 Apr 2006 18:47:34 -0400 (EDT)

> Hey,
> 
> I have a kernel module that uses unregister_qdisc and register_qdisc, whenever i try to insert the module I get:
> /lib/modules/2.4.32/kernel/net/sched/sch_xcp.o: /lib/modules/2.4.32/kernel/net/sched/sch_xcp.o: unresolved symbol unregister_qdisc
> /lib/modules/2.4.32/kernel/net/sched/sch_xcp.o: /lib/modules/2.4.32/kernel/net/sched/sch_xcp.o: unresolved symbol register_qdisc
> 
> Am i missing some sort of support in the kernel?

Make sure CONFIG_NET_SCHED is enabled and that you compiled your module against
that kernel.

Where does this sch_xcp come from?  It's not in the vanilla sources.

Also, please direct networking questions to the netdev@vger.kernel.org
mailing list which I have added to the CC:.
