From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Fri, 13 Aug 2004 17:39:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040813173924.6d05be15.davem@redhat.com>
References: <20040812165954.00429e65.davem@redhat.com>
	<20040813090314.448c971d@dell_ss3.pdx.osdl.net>
	<20040813093838.6961c0d4.davem@redhat.com>
	<20040813215602.GA15870@gondor.apana.org.au>
	<20040813151923.3311b4f0.davem@redhat.com>
	<20040814003428.GA17760@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040814003428.GA17760@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 14 Aug 2004 10:34:28 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> > Ok I see now.  I've added your patch, it seems correct.
> 
> Thanks.  I presume you've reversed the previous patch as well?

Yes and I cured the one typo in it two, idev-->in_dev :-)

> BTW, it looks like you can remove inetdev_lock altogether.  All its
> users already assume that they don't race against each other by
> taking the rtnl lock.

Possibly, I'll have a look.
