From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPCOMP] Exclude IPCOMP header from props.header_len
Date: Tue, 6 Jul 2004 14:11:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706141105.3b8920ba.davem@redhat.com>
References: <20040706123127.GA18271@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040706123127.GA18271@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 6 Jul 2004 22:31:27 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch changes the value of props.header_len for IPCOMP to
> exclude the IPCOMP header.  The reason is that the IPCOMP header
> is added only if the packet is compressible.  That is, if the
> size of the compressed payload plus the size of the IPCOMP header
> is less than that of the original payload.
> 
> This means that the IPCOMP encapsulation does not impose any
> overhead at all as far as the MTU is concerned.  The current
> code incorrectly reduces the MTU by the size of the IPCOMP
> header.
> 
> As a side-effect, this means that we don't have to move the
> IP header around when IPCOMP is used.

Very nice patch Herbert, applied.
