From: Thomas Graf <tgraf@suug.ch>
Subject: Re: memory leak in net/sched/ipt.c?
Date: Wed, 23 Mar 2005 13:55:16 +0100
Message-ID: <20050323125516.GP3086@postel.suug.ch>
References: <E1DE44X-0001QM-00@gondolin.me.apana.org.au> <1111581618.1088.72.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Yichen Xie <yxie@cs.stanford.edu>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
        kaber@trash.net
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1111581618.1088.72.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1111581618.1088.72.camel@jzny.localdomain> 2005-03-23 07:40
> On Wed, 2005-03-23 at 06:30, Herbert Xu wrote:
> > Yichen Xie <yxie@cs.stanford.edu> wrote:
> > > Is the memory block allocated on line 315 leaked every time tcp_ipt_dump 
> > > is called?
> > 
> > It seems to be.  This patch should free it.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

> Just a small correction to patchlet:
> The second kfree should check for existence of t.

t is either valid or NULL so it's not a problem, unless you want
to create janitor work of course. ;->
