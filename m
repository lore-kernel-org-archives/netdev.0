From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [TCP] Fixed bug that hid sockets in tcp_diag
Date: Tue, 5 Oct 2004 22:22:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005222202.0d1d9be0.davem@davemloft.net>
References: <20041006035801.GA15940@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041006035801.GA15940@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 6 Oct 2004 13:58:01 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch squashes a bug in tcp_diag which was created when the
> sk_* loops replaced the original for loops.  It's a pity that these
> sk_*/hlist_*/list_* loops don't take an arbitrary expression as an
> argument for continue.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks a lot for fixing this bug Herbert, patch applied.

Did you send this patch to the original bug reporter for
testing?  What was the result?
