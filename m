From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Sun, 15 Aug 2004 20:08:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040815200838.1f971350.davem@redhat.com>
References: <20040813093838.6961c0d4.davem@redhat.com>
	<20040813215602.GA15870@gondor.apana.org.au>
	<20040813151923.3311b4f0.davem@redhat.com>
	<20040814003428.GA17760@gondor.apana.org.au>
	<20040813173924.6d05be15.davem@redhat.com>
	<20040814005411.GA18350@gondor.apana.org.au>
	<20040814012513.GA721@gondor.apana.org.au>
	<20040814013030.GA2042@gondor.apana.org.au>
	<20040814050848.GA11874@gondor.apana.org.au>
	<20040815190823.654bf2d5.davem@redhat.com>
	<20040816024329.GA8127@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040816024329.GA8127@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 16 Aug 2004 12:43:30 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> It will return zero if there is no in_dev at all.  Perhaps what
> we should do is get inet_select_addr() to get the address from
> other devices in that case as well?

It does that now, look at how it iterates over dev_base's
list.
