From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] linux 2.6.x.x net/sched/sch_api.c -- more comment
 reviews
Date: Mon, 13 Sep 2004 15:31:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913153146.161128d0.davem@davemloft.net>
References: <20040913215944.33830.qmail@web90010.mail.scd.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: S P <speattle@yahoo.com>
In-Reply-To: <20040913215944.33830.qmail@web90010.mail.scd.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 13 Sep 2004 14:59:44 -0700 (PDT)
S P <speattle@yahoo.com> wrote:

Your email client linewraps the patches and also transforms
tabs into spaces making your patches un-applyable.  Please fix
for future submissions, thanks.

Now, onto the patch itself.  I think we're adding more tense
errors than we're removing.  For example:

> -   All real intelligent work is done inside qdisc
> modules.
> +   All real intelligent work is done inside each
> qdisc modules.

'each' indicates singularity, yes "modules" is still
plural.  I would change it instead to:

	All the real intelligent work is done inside
	the qdisc modules.

> -   but it does not mean that queue is empty, it just
> means that
> -   discipline does not want to send anything this
> time.
> +   but it does not mean the queue is empty; it means
> that
> +   the discipline does not want to send anything this
> time.

This one looks fine.

> -   For complicated disciplines with multiple queues
> q->q is not
> -   real packet queue, but however q->q.qlen must be
> valid.
> +   For complicated disciplines with multiple queues,
> q->q is not
> +   real packet queue whereas q->q.qlen must be valid.

Looks fine, we're missing an articles here.
So maybe the final version of this verse is:

	For complicated disciplines with multiple queues,
	q->q is not a real packet queue whereas q->q.qlen
	must be valid.

The rest looks fine.
