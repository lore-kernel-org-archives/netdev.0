From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Wed, 22 Sep 2004 04:48:05 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4150E7E5.2000001@eurodev.net>
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

We are thinking in two different things:

a) You think about netlink sockets as a method to pass information to 
kernel space via command line, in that case dump is ok.

b) I'm thinking about netlink sockets as a method to generate event 
notifications. My benchmark tool just want to emulate that N events 
happen in a *very* short period of time (worst case), that implies 
sending N messages. So, forget that my tool sends previously a message 
to generate those N messages.

But I'm intrigued about something

jamal wrote:

>For a test i typically have something adding say 10K items (actions in
>my case, but could be ipsec policies) and then try to dump them. On my
>xeon i get an overrun after about 6K items are dumped.
>

Jamal, you're getting an overrun dumping ipsec policies. If I'm not 
wrong, that tool is doing that as dump operation, but that this 
shouldn't happen by using dump. Am I missing something?

I would like to have a way to send notifications via netlink sockets 
without losing congestion control ability, that is, without losing 
messages because of an overrun.

regards,
Pablo
