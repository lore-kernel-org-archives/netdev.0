From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Fri, 24 Sep 2004 03:19:12 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41537610.1040403@eurodev.net>
References: <1095633569.1047.107.camel@jzny.localdomain> <20040919231734.GA10124@gondor.apana.org.au> <1095647944.1046.206.camel@jzny.localdomain> <20040920025802.GA11567@gondor.apana.org.au> <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net> <20040922000503.GA13218@gondor.apana.org.au> <4150E7E5.2000001@eurodev.net> <20040922045239.GA19573@gondor.apana.org.au> <1095854920.1047.64.camel@jzny.localdomain> <20040923120707.GB32624@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040923120707.GB32624@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Herbert,

Herbert Xu wrote:

>On Wed, Sep 22, 2004 at 08:08:40AM -0400, jamal wrote:
>  
>
>>Since netlink is being used for a lot of things now, it may be time to
>>obsolete those assumptions. 
>>    
>>
>
>I'm not against changes.  But so far I haven't seen anything concrete
>about what these new things are yet :)
>  
>

Nothing mysterious :), people are willing to put more and more things in 
kernel space, so I wanted to evaluate netlink sockets as a method to 
pass information from kernel to user space and vice-versa.

I think that, instead of putting all the things in kernel space, a 
kernel component can provide an API to user space programs to interact 
with them, so I wanted to evaluate them to figure out what they could do 
and what they could't do at this moment. I can also focus this to 
component replication.

regards,
Pablo
