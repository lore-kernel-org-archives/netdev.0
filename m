From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Fri, 13 Aug 2004 15:19:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040813151923.3311b4f0.davem@redhat.com>
References: <20040812165954.00429e65.davem@redhat.com>
	<20040813090314.448c971d@dell_ss3.pdx.osdl.net>
	<20040813093838.6961c0d4.davem@redhat.com>
	<20040813215602.GA15870@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040813215602.GA15870@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 14 Aug 2004 07:56:02 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Now had you put this barrier between the reading of ip_ptr and
> the checking of in_dev->dead, then the race would've been closed.
> 
> But I still prefer to move the work into inetdev_destroy.

Ok I see now.  I've added your patch, it seems correct.
