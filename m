From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Allowing netlink_family to be any integer (was: [PATCH 2.6] iptables CLUSTERIP target)
Date: Fri, 22 Oct 2004 22:25:33 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022122533.GA9713@gondor.apana.org.au>
References: <20041021142527.GG3551@sunbeam.de.gnumonks.org> <E1CKkWZ-0005x5-00@gondolin.me.apana.org.au> <20041021225315.GH19714@rei.reeler.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harald Welte <laforge@netfilter.org>, lmb@suse.de, ahu@ds9a.nl,
        hch@infradead.org, netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20041021225315.GH19714@rei.reeler.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 22, 2004 at 12:53:15AM +0200, Thomas Graf wrote:
> 
> The only real problem I see is sk_protocol being only 8bit as
> limiting factor.

Well we wouldn't be using sk_protocol to look things up anymore.
We'd be holding a reference on the family directly once the socket
is created.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
