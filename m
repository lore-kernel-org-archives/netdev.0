From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] MASQUERADE / policy routing ("Route send us somewhere else")
Date: Tue, 31 Aug 2004 12:20:53 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C1yGT-000859-00@gondolin.me.apana.org.au>
References: <20040831013841.GA5824@sunbeam.de.gnumonks.org>
Cc: davem@davemloft.net, netfilter-devel@lists.netfilter.org,
        rusty@rustcorp.com.au, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: laforge@netfilter.org (Harald Welte)
In-Reply-To: <20040831013841.GA5824@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Harald Welte <laforge@netfilter.org> wrote:
> 
> I've seen a number of users commenting out that check or even starting
> to use the iptables ROUTE target (ugly) to get it working in their
> setup.  Or they start to use SNAT with scripts in PPP if-up to update
> the ruleset with the new dynamic IP :(

Yes I had to convert all my MASQUERADE rules over to SNAT due to this
problem.  Unfortunately I had to convert them back again because SNAT
doesn't do an automatic flush which MASQUERADE does.  Without the flush
it's pretty useless when your interface address changes often.

So it would be good to know why the oif key is a bad idea.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
