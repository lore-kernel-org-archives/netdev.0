From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPsec xfrm resolution
Date: Sat, 19 Feb 2005 13:29:25 +0100
Message-ID: <42173125.3040505@trash.net>
References: <20050209085251.GA9030@gondor.apana.org.au> <420B9DF1.3020704@trash.net> <20050210202810.GA1609@gondor.apana.org.au> <42144C3F.2060501@trash.net> <20050217091137.GA9476@gondor.apana.org.au> <42152841.5000707@trash.net> <20050218100854.GA19427@gondor.apana.org.au> <4216D6B4.5070901@trash.net> <20050219092314.GA8153@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050219092314.GA8153@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>On Sat, Feb 19, 2005 at 07:03:32AM +0100, Patrick McHardy wrote:
>  
>
>>- netfilter LOCAL_OUT hook sees incorrect output device
>>- strict source routing check done with incorrect rt_gateway
>>    
>>
>
>Once you take the above into account these turn out to be non-issues.
>If the optional SA is transport mode, then the route is identical with
>or without it.  If it's tunnel mode, then we must perform the IPIP
>encapsulation regardless.
>
This is not what happens currently. If an optional IPCOMP SA is missing
it is skipped entirely. It is also legal to configure an optional
ah/esp tunnel, although we don't accept such packets if the SA isn't
present.

Regards
Patrick
