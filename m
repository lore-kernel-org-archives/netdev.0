From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [TCP] Fixed mss in tcp_init_cwnd
Date: Mon, 27 Sep 2004 12:00:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927120031.55fb4a49.davem@davemloft.net>
References: <20040927080828.GA12056@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040927080828.GA12056@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Sep 2004 18:08:28 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> The MSS in tcp_init_cwnd should be the real one instead of the TSO value.

This happens too early in the connections lifetime
to make a difference for anything.

It happens on the first move to ESTABLISHED state, and
therefore by definition before we try to send any data
on the connection.

You're barking up the wrong tree in the search for these
TSO problems.  Instead, I'd recommend looking seriously at
the tcp_clean_rtx_queue() partial ack'ing stuff I spoke
about yesterday.
