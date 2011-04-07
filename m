From: David Miller <davem@davemloft.net>
Subject: Re: problem of "ipv4: revert Set rt->rt_iif more sanely on output
 routes."
Date: Thu, 07 Apr 2011 13:58:49 -0700 (PDT)
Message-ID: <20110407.135849.104066788.davem@davemloft.net>
References: <877hb6sf43.fsf@devron.myhome.or.jp>
	<8739lusbvz.fsf@devron.myhome.or.jp>
	<87wrj6qx5a.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hirofumi@mail.parknet.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54266
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750886Ab1DGU70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 16:59:26 -0400
In-Reply-To: <87wrj6qx5a.fsf@devron.myhome.or.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Date: Thu, 07 Apr 2011 17:32:49 +0900

> OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> writes:
> 
>> This patch seems to work for avahi-daemon without any warning.
>>
>> BTW, the above meant change from (there was before) "fl.iif" to
>> "rt_route_iif"? If so, this patch is not enough. I'm not sure
>>
>> +	rth->rt_route_iif = 0;
>> +	rth->rt_iif	= oldflp4->flowi4_oif ? : dev_out->ifindex;
>>
>> is correct one or not. Please review.
> 
> Forgot the patch.

I am reviewing your patch right now, thank you so much for working
on this bug.
