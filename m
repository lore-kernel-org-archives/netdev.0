From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH BUGFIX] pkt_sched: fix little service anomalies and
 possible crashes of qfq+
Date: Wed, 26 Dec 2012 15:13:55 -0800 (PST)
Message-ID: <20121226.151355.2215825989495032073.davem@davemloft.net>
References: <1355938266-18459-1-git-send-email-paolo.valente@unimore.it>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rizzo@iet.unipi.it, fchecconi@gmail.com
To: paolo.valente@unimore.it
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1355938266-18459-1-git-send-email-paolo.valente@unimore.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paolo valente <paolo.valente@unimore.it>
Date: Wed, 19 Dec 2012 18:31:06 +0100

> +	/*
> +	 * The next assignment may let
> +	 * agg->initial_budget > agg->budgetmax
> +	 * hold, but this does not cause any harm
> +	 */

Please format comments in the networking:

	/* Like
	 * this.
	 */

and

	/*
	 * Never
	 * like this.
	 */

I know this file is full of exceptions, but that error is to be
corrected rather than expanded.

> +	/*
> +	 * If lmax is lowered, through qfq_change_class, for a class
> +	 * owning pending packets with larger size than the new value of lmax,
> +	 * then the following condition may hold.
> +	 */

Likewise.

And I'm not applying this until someone familiar with this code
does some review of this patch.  These are seriously non-trivial
changes.
