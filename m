From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PATCH: IPSEC acquire in presence of multiple managers
Date: Sat, 26 Mar 2005 11:30:58 +1100
Message-ID: <20050326003058.GA22930@gondor.apana.org.au>
References: <1111795927.1089.749.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Shinta Sugimoto <shinta.sugimoto@ericsson.com>,
        netdev <netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1111795927.1089.749.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Mar 25, 2005 at 07:12:07PM -0500, jamal wrote:
> 
> Acquire should be supported by both pfkey and netlink.
> However, it stops to send acquire message from the kernel on first
> success.
> It is possible that one or the other manager maybe passively monitoring
> and needs to see those messages.

Yes that's a good catch.

One problem though is that if theal real KM is dead but the passive
monitor is still there then the kernel will have to wait for the
larval states to time out.

It can happen without the patch too if the KM dies after the message
is delivered.  This will make it slightly more likely.

I guess that's something we'll just have to live with.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
