From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Fix ICMP tempsel
Date: Sat, 19 Feb 2005 19:55:36 +0100
Message-ID: <42178BA8.4090305@trash.net>
References: <4217266F.6090700@trash.net> <20050219184351.GB10773@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Maillist netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050219184351.GB10773@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>I know this comment is probably a bit late but why didn't we simply put
>type/code into sport/dport in struct flowi instead of introducing the
>monstrosities of xfrm_flowi_sport/xfrm_flowi_dport?
>
>Something like
>
>struct {
>	__u16	type;
>	__u16	code;
>} icmpt;
>
>would've done (and still would do) the trick, no?
>
I agree, that is better.

Regards
Patrick
