From: =?ISO-2022-JP?B?TWlrYSBQZW50dGlsYSI=?= <mika.penttila@kolumbus.fi>
Subject: Re: [AH6] Rearrange routing headers
Date: Sun, 25 Jul 2004 14:26:12 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410398D4.2080608@kolumbus.fi>
References: <20040724083709.GA9416@gondor.apana.org.au> <200407250410.03741.kazunori@miyazawa.org> <20040725080347.GA20251@gondor.apana.org.au> <200407251532.13292.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kazunori Miyazawa <kazunori@miyazawa.org>
In-Reply-To: <200407251532.13292.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Kazunori Miyazawa wrote:

>2004/07/25(日) 17:03、Herbert Xu  wrote:
>  
>
>>On Sun, Jul 25, 2004 at 04:10:03AM +0900, Kazunori Miyazawa wrote:
>>    
>>
>>>To process routing header correctly, we should fix the codes which
>>>calls ip6_dst_lookup in ipv6 because there is difference of destinatio
>>>addresses for routing resolution and looking up xfrm_policy.
>>>      
>>>
>>What do you mean? Isn't the code in icmp.c/raw.c/tcp_ipv6.c/udp.c
>>that sets fl.fl6_dst using opt->srcrt enough?
>>
>>If not then we'll need to change IPv4 as well.
>>
>>    
>>
>routing is looked up with srcrt but xfrm is looked up with final
>destination, isn't it? we have the codes in our repository.
>sorry, I'm goring back to home from OLS2004.
>I'll send the patch when I will arrive at home.
>  
>

We are not doing this in ipv4 either. But it makes sense to do xfrm
lookup based on the final destination.

>Thank you,
>
>--Kazunori Miyazawa
>  
>


--Mika
