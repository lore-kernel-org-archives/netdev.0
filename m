From: S P <speattle@yahoo.com>
Subject: Re: [PATCH] linux 2.6.x.x net/sched/sch_api.c -- more comment reviews
Date: Tue, 14 Sep 2004 08:35:32 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914153532.89992.qmail@web90008.mail.scd.yahoo.com>
References: <20040913153146.161128d0.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040913153146.161128d0.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 
> Please fix
> for future submissions, thanks.
will use attachments.

> 
> Now, onto the patch itself.  I think we're adding
> more tense
> errors than we're removing.  For example:
> 
> > -   All real intelligent work is done inside qdisc
> > modules.
> > +   All real intelligent work is done inside each
> > qdisc modules.
> 
> 'each' indicates singularity, yes "modules" is still
> plural.  I would change it instead to:
> 
> 	All the real intelligent work is done inside
> 	the qdisc modules.

I think I meant inside each of the module.  Not sure
if your change conveys that.  I did notice it's still
akward, but I didn't want to take away the emphasis of
individuality if the original author meant it.



> Looks fine, we're missing an articles here.
> So maybe the final version of this verse is:
> 
> 	For complicated disciplines with multiple queues,
> 	q->q is not a real packet queue whereas q->q.qlen
> 	must be valid.
> 
> The rest looks fine.
Yup, I thought I lost that 'a' somewhere.  And, the
comma.  (so the code readers don't run out of breathe)
> 
> 
Thanks.
So should I resubmit w/ the changes?
Wasn't sure if you just applied w/ the changes or are
returning for me to apply the fixes.

:)


		
__________________________________
Do you Yahoo!?
Yahoo! Mail - 50x more storage than other providers!
http://promotions.yahoo.com/new_mail
