From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: PATCH: IPSEC xfrm events
Date: Fri, 01 Apr 2005 23:19:45 +0900
Message-ID: <424D5881.4010005@linux-ipv6.org>
References: <1112319441.1089.83.camel@jzny.localdomain>	 <20050401042106.GA27762@gondor.apana.org.au>	 <1112353398.1096.116.camel@jzny.localdomain>	 <20050401114258.GA2932@gondor.apana.org.au>	 <1112358278.1096.160.camel@jzny.localdomain>	 <20050401123554.GA3468@gondor.apana.org.au> <1112360379.1096.193.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca, Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <1112360379.1096.193.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Jamal and Herbert,


jamal wrote:
> Let me review first. If it is valuable (we may have to leave expire
> alone). If i can get it done within next day or two fine - else if i get
> busyed out elsewhere i will hand it to you. Actually if you have plenty
> cycles and are very enthusiastic about this i can hand it to you right
> now ;-> Masahide and myself have some momentum going right now but i
> dont think this will be that disruptive.
> 
> 
>>You're right that the RFC isn't very clear.
>>
>>Let's forget about the RFC and simply consider the usefulness of this.
>>I contend that it is useful to see a FLUSH notification even when
>>it flushed nothing.
>>
>>The reason is that this is an indication to all listeners that the
>>database is completely empty.
>>
> 
> 
> Ok, let me hear from Masahide-san: If he still holds the same opinion as
> you then i will make the change.

I think FLUSH should be sent in such case.
Because flushing empty SADB/SPD is not an error (at current code),
it is reasonable to broadcast it.

Regards,

-- 
Masahide NAKAMURA
