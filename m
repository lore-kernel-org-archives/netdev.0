From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/4] SGI Altix cross partition functionality (1st revision)
Date: Tue, 24 Aug 2004 20:13:43 +0100
Sender: linux-ia64-owner@vger.kernel.org
Message-ID: <20040824201343.A32110@infradead.org>
References: <412B823E.mailxAMX1HROPJ@aqua.americas.sgi.com> <20040824182222.GA13961@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-ia64@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-ia64-owner@vger.kernel.org>
To: Dean Nelson <dcn@sgi.com>
Content-Disposition: inline
In-Reply-To: <20040824182222.GA13961@sgi.com>; from dcn@sgi.com on Tue, Aug 24, 2004 at 01:22:22PM -0500
List-Id: netdev.vger.kernel.org

> --- bk-linux-2.6.orig/kernel/sched.c	2004-08-23 14:39:35.000000000 -0500
> +++ bk-linux-2.6/kernel/sched.c	2004-08-24 07:29:11.000000000 -0500
> @@ -2814,6 +2814,7 @@
>  {
>  	return setscheduler(pid, policy, param);
>  }
> +EXPORT_SYMBOL(sys_sched_setscheduler);

As said previously you're not supposed to mess with this one.

>  long nr_swap_pages;
>  int numnodes = 1;
> +EXPORT_SYMBOL(numnodes);

Looing at the two routines that use this I think those two should always
go into the core kernel code.  That way you also get rid of the
pda_percpu export.

