From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Using Fwmark as SPD filter.
Date: Sat, 19 Mar 2005 21:15:20 +1100
Message-ID: <E1DCazI-0003sx-00@gondolin.me.apana.org.au>
References: <423BF9BA.8090408@protactive.nl>
Cc: netdev@oss.sgi.com
To: ludo@protactive.nl (Ludo Stellingwerff)
In-Reply-To: <423BF9BA.8090408@protactive.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ludo Stellingwerff <ludo@protactive.nl> wrote:
> 
> In general, is this work a waste of time or am I hitting something here?

Yes you're hitting the right spot :)

This is a planned feature.  We just need to fix the bundle structure
so that they live in the flow cache instead of the policy to make this
workable.

As to your patch: There is no point in adding more Linux-specific extensions
when we already have a Linux-specific netlink interface that supports fwmark.
So these efforts would be better spent in converting whatever application
you're using (e.g., racoon) over to netlink.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
