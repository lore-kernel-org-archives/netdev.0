From: jamal <hadi@cyberus.ca>
Subject: Re: memory leak in net/sched/ipt.c?
Date: 23 Mar 2005 07:40:18 -0500
Message-ID: <1111581618.1088.72.camel@jzny.localdomain>
References: <E1DE44X-0001QM-00@gondolin.me.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Yichen Xie <yxie@cs.stanford.edu>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
        kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DE44X-0001QM-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-03-23 at 06:30, Herbert Xu wrote:
> Yichen Xie <yxie@cs.stanford.edu> wrote:
> > Is the memory block allocated on line 315 leaked every time tcp_ipt_dump 
> > is called?
> 
> It seems to be.  This patch should free it.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> BTW, please report networking bugs to netdev@oss.sgi.com.
> 

Thanks for pointing this out - I _know_ its in the kernel list FAQ.
I was sitting beside R Gooch when he added "thou shalt post to netdev".
And of course i am gonna bitch about it every time someone doesnt
post to netdev;-> 

Just a small correction to patchlet:
The second kfree should check for existence of t.

cheers,
jamal

> Thanks,
