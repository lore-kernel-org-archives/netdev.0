From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH: IPSEC acquire in presence of multiple managers
Date: 26 Mar 2005 13:41:27 -0500
Message-ID: <1111862486.1090.880.camel@jzny.localdomain>
References: <E1DF15m-0006JT-00@gondolin.me.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, nakam@linux-ipv6.org,
        shinta.sugimoto@ericsson.com, netdev <netdev@oss.sgi.com>,
        Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DF15m-0006JT-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


You could say i am obssesed by this aquire message - I dont know why;->

I noticed in the absence of a responsive KM, the acquires are sent
forever. Is it 30 seconds and may be degenerating to 60 seconds?
In the meantime my ping is sitting there not giving me back the prompt.
I suspect this is so as to make it reliable and maybe aggrevated by the
fact i can now passively monitor with ip xfrm mon.

Shouldnt there be a _configurable_ timer and number of retries?
all attempts of reliability at least put an upper limit.
Perhaps the km states could be extended a little? i.e instead of
just ACQUIRING maybe some intermidiate states are needed (sort of like
neighbor discovery or ARP). And when it looks hopeless you just stop.

Is there a standard maybe that defines such behavior?

cheers,
jamal
