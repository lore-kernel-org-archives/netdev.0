From: James Morris <jmorris@redhat.com>
Subject: Re: [ESP] Only one algorithm is required
Date: Sat, 14 Aug 2004 10:16:17 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0408141012510.26617-100000@dhcp83-76.boston.redhat.com>
References: <20040814105245.GA20646@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040814105245.GA20646@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 14 Aug 2004, Herbert Xu wrote:

> Both encryption and authentication are optional for ESP.  However, at
> least one of them must be present.  The following patch changes init_state
> to match that specification.

This is userland level policy and I don't think the kernel should be
enforcing this.


- James
-- 
James Morris
<jmorris@redhat.com>
