From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Allowing netlink_family to be any integer (was: [PATCH 2.6] iptables CLUSTERIP target)
Date: Fri, 22 Oct 2004 21:39:39 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022113939.GA812@gondor.apana.org.au>
References: <E1CKkWZ-0005x5-00@gondolin.me.apana.org.au> <1098444579.1112.66.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
        Harald Welte <laforge@netfilter.org>, lmb@suse.de, ahu@ds9a.nl,
        hch@infradead.org, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1098444579.1112.66.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 22, 2004 at 07:29:39AM -0400, jamal wrote:
> 
> Evgeniy Polyakov(aka mr. Sean Paul) posted code a while back for
> something that uses netlink that he calls  "kernel Konnector". I think

That patch puts the ID in each message, right?

That would mean paying the lookup cost for each message rather than
once when you create the socket.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
