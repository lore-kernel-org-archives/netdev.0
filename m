From: James Morris <jmorris@redhat.com>
Subject: Re: pskb change in dst->output
Date: Wed, 7 Jul 2004 19:33:18 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0407071931480.28863-100000@thoron.boston.redhat.com>
References: <20040707231221.GA30565@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040707231221.GA30565@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 8 Jul 2004, Herbert Xu wrote:

> Thanks.  I have no problems with that.  But ip_mc_output() as far
> as I can see does not call dst_output.
> 
> So is there a caller to dst_output that does this as well?

The TCP code often clones skbs to be transmitted.


- James
-- 
James Morris
<jmorris@redhat.com>
