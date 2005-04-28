From: Patrick McHardy <kaber@trash.net>
Subject: Re: patch: policy update by id
Date: Thu, 28 Apr 2005 14:09:42 +0200
Message-ID: <4270D286.7060301@trash.net>
References: <20050427233924.GA22238@gondor.apana.org.au> <1114650816.7663.13.camel@localhost.localdomain> <20050428012135.GA22950@gondor.apana.org.au> <20050428013014.GA23043@gondor.apana.org.au> <1114653140.7663.36.camel@localhost.localdomain> <20050428020754.GA23326@gondor.apana.org.au> <20050427194356.58a3e618.davem@davemloft.net> <20050428025644.GA23823@gondor.apana.org.au> <1114658160.7663.102.camel@localhost.localdomain> <20050428032045.GA24041@gondor.apana.org.au> <20050428114308.GX577@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, jamal <hadi@cyberus.ca>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050428114308.GX577@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Herbert Xu <20050428032045.GA24041@gondor.apana.org.au> 2005-04-28 13:20
> 
>>iptables -D INPUT 2
> 
> Except for when another iptables instance has modified the ordering of
> the rules by inserting or deleting a rule in the meantime. Please do
> not adopt this scheme, it's completely unreliable.

Yes, if you don't know the ordering of your ruleset it is unreliable :)

Regards
Patrick
