From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Allowing netlink_family to be any integer (was: [PATCH 2.6] iptables CLUSTERIP target)
Date: Sat, 23 Oct 2004 09:16:07 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022231607.GA14365@gondor.apana.org.au>
References: <20041021142527.GG3551@sunbeam.de.gnumonks.org> <E1CKkWZ-0005x5-00@gondolin.me.apana.org.au> <20041022160559.28f9c540.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: laforge@netfilter.org, lmb@suse.de, ahu@ds9a.nl, hch@infradead.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041022160559.28f9c540.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 22, 2004 at 04:05:59PM -0700, David S. Miller wrote:
> On Fri, 22 Oct 2004 07:31:07 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > Initially I considered an interface where kernel users can register
> > themselves using a string as the key.  But I soon realised that we
> > could simply allow the netlink_family field to be an arbitrary integer
> > that is used as a key to a hash table.
> 
> (I assume you mean "nl_family" not "netlink_family" :-)

I'm no plans yet in taking over all address families :)
I'm only referring to the third argument in socket(2).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
