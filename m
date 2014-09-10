From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: clean up anycast when an interface is
 destroyed
Date: Wed, 10 Sep 2014 13:58:40 -0700 (PDT)
Message-ID: <20140910.135840.133555874665251669.davem@davemloft.net>
References: <20140910102714.GB21267@kria>
	<CAHA+R7ODewXP69ULsR0RD+c3BEfMa90zATRjHF3dC9Dkv7jgZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sd@queasysnail.net, netdev@vger.kernel.org,
	hannes@stressinduktion.org
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43323 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753065AbaIJU6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 16:58:44 -0400
In-Reply-To: <CAHA+R7ODewXP69ULsR0RD+c3BEfMa90zATRjHF3dC9Dkv7jgZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Wed, 10 Sep 2014 10:15:01 -0700

> On Wed, Sep 10, 2014 at 3:27 AM, Sabrina Dubroca <sd@queasysnail.net> wrote:
>> diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
>> index ff2de7d9d8e6..a1bf80574bfe 100644
>> --- a/net/ipv6/anycast.c
>> +++ b/net/ipv6/anycast.c
>> @@ -351,6 +351,28 @@ static int ipv6_dev_ac_dec(struct net_device *dev, const struct in6_addr *addr)
>>         return __ipv6_dev_ac_dec(idev, addr);
>>  }
>>
>> +/* Device is being destroyed: clean up */
> 
> This comment is useless.

Agreed, please remove this and respin that patch.

Thanks.
