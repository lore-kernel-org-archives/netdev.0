From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9 net-next] ipv6: replace if/BUG by BUG_ON
Date: Tue, 31 Mar 2015 11:17:52 -0400 (EDT)
Message-ID: <20150331.111752.1605776715849912657.davem@davemloft.net>
References: <1427749998-28464-1-git-send-email-fabf@skynet.be>
	<1427749998-28464-4-git-send-email-fabf@skynet.be>
	<551A1983.40408@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fabf@skynet.be, linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	pablo@netfilter.org, kadlec@blackhole.kfki.hu,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org
To: hideaki.yoshifuji@miraclelinux.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <551A1983.40408@miraclelinux.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Date: Tue, 31 Mar 2015 12:50:27 +0900

> Hi,
> 
> Fabian Frederick wrote:
>> Signed-off-by: Fabian Frederick <fabf@skynet.be>
>> ---
>>  net/ipv6/addrconf.c                     | 3 +--
>>  net/ipv6/esp6.c                         | 3 +--
>>  net/ipv6/netfilter/nf_conntrack_reasm.c | 3 +--
>>  3 files changed, 3 insertions(+), 6 deletions(-)
>> 
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index 2660263..e205918 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -4805,8 +4805,7 @@ static int inet6_set_link_af(struct net_device *dev, const struct nlattr *nla)
>>  	if (!idev)
>>  		return -EAFNOSUPPORT;
>>  
>> -	if (nla_parse_nested(tb, IFLA_INET6_MAX, nla, NULL) < 0)
>> -		BUG();
>> +	BUG_ON(nla_parse_nested(tb, IFLA_INET6_MAX, nla, NULL) < 0);
>>  
> 
> NACK, I do not prefer using BUG_ON() with side effects.

Agreed, I do not like these changes at all and will not be
applying them.
