From: David Miller <davem@davemloft.net>
Subject: Re: VLAN over GRE segfault
Date: Fri, 18 Mar 2011 15:16:43 -0700 (PDT)
Message-ID: <20110318.151643.58424378.davem@davemloft.net>
References: <4D830AF9.8040007@diddi.se>
	<1300444047.2888.18.camel@edumazet-laptop>
	<20110318192859.GA26156@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, diddi@diddi.se, netdev@vger.kernel.org,
	kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43763
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932918Ab1CRWQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 18:16:05 -0400
In-Reply-To: <20110318192859.GA26156@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 18 Mar 2011 14:28:59 -0500

> On Fri, Mar 18, 2011 at 11:27:27AM +0100, Eric Dumazet wrote:
>>
>> This uncover a bug in vlan code.
>> 
>> We should make sure vlan devices take into account their
>> real_dev->needed_headroom or we risk a crash in ipgre_header(), because
>> we dont have enough room to push IP header in skb.
>> 
>> Reported-by: Diddi Oscarsson <diddi@diddi.se>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: Patrick McHardy <kaber@trash.net>
>> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
