From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Wed, 22 Sep 2004 02:24:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4150C64E.80900@eurodev.net>
References: <E1C8way-0000aH-00@gondolin.me.apana.org.au> <20040919120249.GA5963@gondor.apana.org.au> <414DF11C.1080505@eurodev.net> <20040919215915.GB9573@gondor.apana.org.au> <1095633569.1047.107.camel@jzny.localdomain> <20040919231734.GA10124@gondor.apana.org.au> <1095647944.1046.206.camel@jzny.localdomain> <20040920025802.GA11567@gondor.apana.org.au> <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net> <20040922000503.GA13218@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040922000503.GA13218@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Herbert,

Herbert Xu wrote:

>On Mon, Sep 20, 2004 at 08:14:42PM +0200, Pablo Neira wrote:
>  
>
>>Here a link to the tool that I use to stress netlink sockets.
>>
>>http://eurodev.net/~pablo/netlinkbench-unicast-1.0.tar.gz
>>    
>>
>
>Thanks for the link.  I'm afraid that your kernel module is simply
>buggy.
>
>First of all as I explained before the kernel must never wait.  It has
>exactly the same effect as extending the receive queue length.
>
>Secondly each of your user-space messages is producing a number of
>replies.  This should be done as a dump operation.  If you do it as
>a dump operation, then you will never get overruns because the kernel
>never sends more than the user can handle.
>  
>

I'll adapt the module to use dump, I still think that I can reproduce 
the problem.

thanks for the review, please stay tuned.

regards,
Pablo
