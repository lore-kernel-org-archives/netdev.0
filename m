From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH: IPSEC acquire in presence of multiple managers
Date: 26 Mar 2005 15:06:25 -0500
Message-ID: <1111867585.1091.909.camel@jzny.localdomain>
References: <E1DF15m-0006JT-00@gondolin.me.apana.org.au>
	 <1111862486.1090.880.camel@jzny.localdomain>
	 <20050326194217.GA9778@gondor.apana.org.au>
	 <20050326194503.GA9826@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, nakam@linux-ipv6.org,
        shinta.sugimoto@ericsson.com, netdev <netdev@oss.sgi.com>,
        Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050326194503.GA9826@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-03-26 at 14:45, Herbert Xu wrote:
> On Sun, Mar 27, 2005 at 05:42:17AM +1000, herbert wrote:
> > 
> > It's only sitting there forever because ping is configured to send
> > packets forever by default.
> > 
> > Try ping -c 1 and things will probably be different.
> 
> Actually it won't.  It will try it forever when the larval state
> expires.  When we fix the xfrm state resolution, we can add a
> knob for this case.

When you get that and need someone to test just post it and i will.

cheers,
jamal
