From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Mon, 20 Sep 2004 20:14:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414F1E12.6010808@eurodev.net>
References: <414D0CCD.90209@eurodev.net>	 <E1C8way-0000aH-00@gondolin.me.apana.org.au>	 <20040919120249.GA5963@gondor.apana.org.au> <414DF11C.1080505@eurodev.net>	 <20040919215915.GB9573@gondor.apana.org.au>	 <1095633569.1047.107.camel@jzny.localdomain>	 <20040919231734.GA10124@gondor.apana.org.au>	 <1095647944.1046.206.camel@jzny.localdomain>	 <20040920025802.GA11567@gondor.apana.org.au> <1095683660.1047.254.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1095683660.1047.254.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

jamal wrote:

>On Sun, 2004-09-19 at 22:58, Herbert Xu wrote:
>  
>
>>AFAICT the problem Pablo is trying to solve is packet loss due to
>>netlink congestion.
>>
>>There might actually be a problem with the kernel not waking up the
>>the user process when we tell it to.  It might even be a scheduling
>>problem.  But we'll need a test-case to assess that.
>>
>>    
>>
>
>Agreed.
>For a test i typically have something adding say 10K items (actions in
>my case, but could be ipsec policies) and then try to dump them. On my
>xeon i get an overrun after about 6K items are dumped.
>  
>
yes, this is exactly what I've observed.

Here a link to the tool that I use to stress netlink sockets.

http://eurodev.net/~pablo/netlinkbench-unicast-1.0.tar.gz

We've set a webpage at the university: 
http://perso.ens-lyon.fr/laurent.lefevre/software/netlinkbench/ but the 
link to download the tool is broken, it will be up soon.

I've make also a version for broadcast sockets but it's basically a copy 
and paste of the unicast tool, I can also send you another link with it.

In nlbench-unicast.c there's a macro to set/unset MSG_DONTWAIT flag to 
make it hit my code or not.

regards,
Pablo
