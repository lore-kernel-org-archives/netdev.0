From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PATCH: IPSEC acquire in presence of multiple managers
Date: Sat, 26 Mar 2005 11:58:55 +1100
Message-ID: <20050326005855.GA23533@gondor.apana.org.au>
References: <1111795927.1089.749.camel@jzny.localdomain> <20050326003058.GA22930@gondor.apana.org.au> <1111798470.1090.774.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Shinta Sugimoto <shinta.sugimoto@ericsson.com>,
        netdev <netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1111798470.1090.774.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Mar 25, 2005 at 07:54:31PM -0500, jamal wrote:
>
> It seems that we dont support any acquires from userspace to kernel

I haven't checked af_key but netlink does support that.  All you have
to do is send messages to the correct multicast group.

Of course whether any of the KMs actually deal with it is a different
story :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
