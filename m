From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 9/11] PKT_SCHED: Cleanup cls_set_class
Date: Wed, 27 Oct 2004 12:58:38 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027105838.GO12289@postel.suug.ch>
References: <20041026222148.GA12289@postel.suug.ch> <20041026222813.GJ12289@postel.suug.ch> <1098867450.1813.37.camel@cyan.cph.tpack.net> <20041027094238.GM12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
Content-Disposition: inline
In-Reply-To: <20041027094238.GM12289@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>  cls_set_class(struct tcf_proto *tp, unsigned long *clp, 
>  	unsigned long cl)
>  {
>  	unsigned long old_cl;
>  	
> -	qdisc_lock_tree(tp->q->dev);
> -

I investigated this bug a bit more to find out why the kernel didn't
lock up during my tests and it seems this lock somehow made it into
while rediffing to split it up into multiple patches. Sorry folks
and thanks again Tommy.
