From: "David S. Miller" <davem@redhat.com>
Subject: Re: old NLMSG_OK fix
Date: Mon, 28 Jun 2004 11:22:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040628112258.31ed64f1.davem@redhat.com>
References: <20040627205133.11d37f0c.davem@redhat.com>
	<E1Besfp-0004hd-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hch@lst.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1Besfp-0004hd-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Jun 2004 19:43:37 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> David S. Miller <davem@redhat.com> wrote:
> > On Sun, 27 Jun 2004 19:15:52 +0200
> > Christoph Hellwig <hch@lst.de> wrote:
> > 
> >> http://oss.sgi.com/projects/netdev/archive/2000-09/msg00001.html
> > 
> > It works because there is always 16 bytes of scratch at the end of an
> > SKB more than was allocated for the actual data.  So blindly deref'ing
> > the nlmsg_len value is fine here.
> 
> Yes but this is also used by user-space appliations where this scratch
> space may not exist.  NETLINK messages can travel from one application
> to another so exploits are possible.

You're right, thanks for pointing this out.  I'll add it to my tree.
