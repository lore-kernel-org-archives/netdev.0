From: James Morris <jmorris@redhat.com>
Subject: Re: [4/4] [IPSEC] Store MTU at each xfrm_dst
Date: Tue, 15 Feb 2005 10:53:11 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0502151050080.29775-100000@thoron.boston.redhat.com>
References: <20050214221607.GC18465@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050214221607.GC18465@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Feb 2005, Herbert Xu wrote:

> Finally this is the patch that sets the MTU values of each xfrm_dst
> and keeps it up-to-date.
>   
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> To recap, at this point we've obtained accurate MTU values at each
> xfrm_dst.  The next step would be to start using it as
> dst_pmtu(xfrm_dst).

Nice work.

The only thing I'd suggest is to consider renaming the new route element
of xfrm_dst to xfrm_dst_route (or xd_route), to make it easier to navigate
the code.  (But the other elements are not distinctive either so perhaps 
some future cleanup could do it).


- James
-- 
James Morris
<jmorris@redhat.com>
