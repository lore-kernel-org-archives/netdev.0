From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6]: Fix policy update bug when increasing priority of
 last policy
Date: Tue, 19 Oct 2004 16:24:12 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4175238C.7010907@trash.net>
References: <E1CJhER-0001vk-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CJhER-0001vk-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>Patrick McHardy <kaber@trash.net> wrote:
>
>>This patch checks for *p != NULL before continuing the loop.
>>    
>>
>
>Unfortunately that doesn't fix it completely.  The real bug is
>the fact that we continue with a bogus p pointing to the deleted
>element.  So what we should do is continue without updating p
>at all.
>  
>
You're right, your patch is better. I've tested
it and it works fine.

Regards
Patrick
