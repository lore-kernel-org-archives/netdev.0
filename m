From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [16/*] [INET] Take IPsec overhead into account in tunnels
Date: Tue, 15 Mar 2005 11:20:52 +0100
Message-ID: <20050315102052.GC23800@xi.wantstofly.org>
References: <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <20050306213214.7d8a143d.davem@davemloft.net> <20050307103536.GB7137@gondor.apana.org.au> <20050308102741.GA23468@gondor.apana.org.au> <20050314102614.GA9610@gondor.apana.org.au> <20050314105313.GA21001@gondor.apana.org.au> <20050314111002.GA29156@gondor.apana.org.au> <20050315091904.GA6256@gondor.apana.org.au> <20050315095837.GA7130@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050315095837.GA7130@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 15, 2005 at 08:58:37PM +1100, Herbert Xu wrote:

> This patch uses dst_mtu instead of dst_pmtu in the various tunnel
> implementations.  As it is they simply ignore the IPsec overhead.
> This leads to bogus MTU values inside the tunnels.

I've not been able to get ipsec-encapsulated ipip/gre tunneling to
work properly (without MTU issues) so far, and never had the time to
properly dig into it.  If this is going to be fixed, that would be
great.


--L
