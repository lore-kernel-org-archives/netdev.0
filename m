From: "David S. Miller" <davem@redhat.com>
Subject: Re: [CRYPTO] Fix stack overrun in crypt()
Date: Wed, 21 Jul 2004 14:58:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040721145815.307c5e39.davem@redhat.com>
References: <20040715114840.GA1325@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040715114840.GA1325@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 15 Jul 2004 21:48:40 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> The stack allocation in crypt() is bogus as whether tmp_src/tmp_dst
> is used is determined by factors unrelated to nbytes and
> src->length/dst->length.
> 
> Since the condition for whether tmp_src/tmp_dst are used is very
> complex, let's allocate them always instead of guessing.
> 
> This fixes a number of weird crashes including those AES crashes
> that people have been seeing with the 2.4 backport + ipt_conntrack.

Applied, thanks Herbert.

> PS I think someone should double-check the logic in the scatterwalk
> stuff, especially the whichbuf bits.

I've looked at this before, when it went in, but I'll double-
check it now.
