From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [INET] Add flags field to ip_tunnel_parm
Date: Wed, 15 Sep 2004 08:06:17 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914220617.GA9213@gondor.apana.org.au>
References: <20040914121617.GA5652@gondor.apana.org.au> <20040914.215205.110659321.yoshfuji@linux-ipv6.org> <20040914212843.GA8925@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040914212843.GA8925@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 15, 2004 at 07:28:43AM +1000, herbert wrote:
> On Tue, Sep 14, 2004 at 09:52:05PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> > 
> > Kernel will get garbage from old binaries,
> > and kernel will break user space if it tries 
> > to get params into old structure.
> 
> The only application that I know of does a memset on the structure
> so it'll be fine.  Are you aware of any user-space applications that
> initialises every field explicitly instead of using memset?

Never mind, I see what you mean now.

I suppose change the ioctl names/numbers is the easiest way now.
I'd love to use netlink but that seems to require a lot of
infrastructure which isn't there currently.
 
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
