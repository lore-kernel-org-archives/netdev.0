From: Patrick McHardy <kaber@trash.net>
Subject: Re: Replace send_unreach with icmp_send
Date: Tue, 15 Mar 2005 21:48:53 +0100
Message-ID: <42374A35.6020308@trash.net>
References: <20050307103536.GB7137@gondor.apana.org.au> <20050308102741.GA23468@gondor.apana.org.au> <20050314102614.GA9610@gondor.apana.org.au> <20050314105313.GA21001@gondor.apana.org.au> <20050314111002.GA29156@gondor.apana.org.au> <20050315091904.GA6256@gondor.apana.org.au> <20050315095837.GA7130@gondor.apana.org.au> <20050315100522.GA7275@gondor.apana.org.au> <20050315102450.0f3f1618.davem@davemloft.net> <42373142.6090902@trash.net> <20050315204006.GB22349@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050315204006.GB22349@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Well it isn't terribly difficult to create a new version of icmp_send
> that does xrlim conditionally.  icmp_send/ipt_REJECT can then call that
> function.
> 
> The main reason I'm looking at getting rid of send_unreach is because
> having two implementations of the same code often leads to bugs.  In
> fact, as it is there are multiple IPsec-related bugs in the ipt_REJECT
> code.

Ok. I can't see any different reason to keep it, so go ahead. I'll take
care of the xrlim stuff later.

Regards
Patrick
