From: "David S. Miller" <davem@redhat.com>
Subject: Re: [ESP] Only one algorithm is required
Date: Sun, 15 Aug 2004 19:55:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040815195546.1e1ae36a.davem@redhat.com>
References: <20040814104807.GA20572@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040814104807.GA20572@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 14 Aug 2004 20:48:07 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I've also added encap_type checks for every transform.  This means
> that people attaching encap objects to AH/IPCOMP/IPIP will now get
> errors.  That should be fine as no major KM does this.
> 
> Please note that the error returned is now EINVAL instead of
> ENOPROTOOPT.  This shouldn't break anything since KMs only test
> the errno from setsockopt() for NAT-T support rather than add_sa
> where it would be too late anyway.

Applied.
