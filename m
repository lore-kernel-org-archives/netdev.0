From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: Allow xt_nat.c and x_tables.c to compiled in
Date: Fri, 14 Sep 2012 13:54:22 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1209141353470.11622@stinky-local.trash.net>
References: <87627hfi69.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87627hfi69.fsf@xmission.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Sep 2012, Eric W. Biederman wrote:

> xt_init in x_tables.c must be called before xt_nat_init in xt_nat.c
> Reorder the makefile so that x_tables.o comes before xt_nat.o in
> netfilter.o.
>
> This allows me to built a kernel with both of these modules compiled in.

Thanks, we've already fixed that, the patch is queued in Pablo's tree.

