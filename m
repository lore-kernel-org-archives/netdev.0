From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2/3] [TCP] Make tcpdiag_bc_run take tcpdiag_entry
Date: Tue, 19 Oct 2004 22:09:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019220959.69919679.davem@davemloft.net>
References: <4164F60C.6080807@cosmosbay.com>
	<E1CFTUz-0007V6-00@gondolin.me.apana.org.au>
	<20041014213030.GA18433@gondor.apana.org.au>
	<20041014213347.GB18433@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041014213347.GB18433@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 15 Oct 2004 07:33:47 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch adds a tcpdiag_entry struct and makes tcpdiag_bc_run use it
> instead of a struct sock.  This will allow us to use tcpdiag_bc_run on
> struct open_request in the next patch.
> 
> Please note that I've left the CONFIG_IPV6 defines in as to support
> ipv6 modules we'll need to modularise tcpdiag itself.  I'll probably
> do that after this is all fixed.
>  
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied, thanks.
