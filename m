From: "David S. Miller" <davem@redhat.com>
Subject: Re: [NATT] Fix uh->len with IP options
Date: Fri, 9 Jul 2004 17:05:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040709170502.58a05039.davem@redhat.com>
References: <20040709114802.GA13344@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040709114802.GA13344@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 9 Jul 2004 21:48:02 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I just noticed that the UDP header length in esp4_output() is incorrect
> when IP options are present (in transport mode).  This patch fixes exactly
> that.

At first I thought you should be using top_iph to compute the options
length, but now I see why it's correct to be using 'iph'.

Applied, thanks.
