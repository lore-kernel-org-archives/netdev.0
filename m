From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Sun, 15 Aug 2004 20:03:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040815200357.6593e861.davem@redhat.com>
References: <20040812165954.00429e65.davem@redhat.com>
	<20040813090314.448c971d@dell_ss3.pdx.osdl.net>
	<20040813093838.6961c0d4.davem@redhat.com>
	<20040813215602.GA15870@gondor.apana.org.au>
	<20040813151923.3311b4f0.davem@redhat.com>
	<20040814003428.GA17760@gondor.apana.org.au>
	<20040813173924.6d05be15.davem@redhat.com>
	<20040814005411.GA18350@gondor.apana.org.au>
	<20040814012513.GA721@gondor.apana.org.au>
	<20040814014048.GA2746@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040814014048.GA2746@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 14 Aug 2004 11:40:48 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Since nobody calls inet_free_ifa directly anymore, we can
> perform the following simplification.

You need to redo this patch because the 3-arg call_rcu() bits
are in there.
