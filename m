From: Patrick McHardy <kaber@trash.net>
Subject: Re: [3/4] [IPSEC] Add route element to xfrm_dst
Date: Tue, 15 Mar 2005 20:05:43 +0100
Message-ID: <42373207.9090308@trash.net>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <42357AF0.4080205@trash.net> <20050314203208.GA15146@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050314203208.GA15146@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Mon, Mar 14, 2005 at 12:52:16PM +0100, Patrick McHardy wrote:
>
>>Since the tunnel dst is not necessarily the last in the bundle anymore,
>>we might miss to initialize some dsts, for example with ipcomp/tunnel +
>>esp/transport. If we have nested tunnels we'll fiddle with entries in
>>the routing cache.
> 
> 
> Sorry, but I don't get it :) First of all what do you mean by the
> tunnel dst?
> 
> If you mean &rt->u.dst then as far as I can see it's still the last
> child in the bundle.  It may also appear in ->route elements earlier
> on but that does not come into play in this loop.

You're right, I must have misread the code somehow. Sorry for the noise.

Regards
Patrick
