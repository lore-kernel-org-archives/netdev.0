From: Patrick McHardy <kaber@trash.net>
Subject: Re: RFC: [PATCH 2/3] netdevice: Fix promiscuity and allmulti overflow
Date: Mon, 16 Jun 2008 12:04:57 +0200
Message-ID: <48563AC9.3000008@trash.net>
References: <48562F45.3040302@cn.fujitsu.com> <4856349C.70201@trash.net> <48563799.4080200@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59012 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbYFPKFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 06:05:02 -0400
In-Reply-To: <48563799.4080200@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> Patrick McHardy said the following on 2008-6-16 17:38:
>>
>> I question the need for this though, userspace can only trigger
>> an increase/decrease by one no matter how often it enables
>> the ALLMULTI/PROMISC flags, and I doubt any codepath in the
>> kernel would lead to an overflow.
>>
> 
> How about mif6_add()?
> Do we have a limit for mif6?

No, so I guess your patch makes sense.

>> If this can really happen it would be better to leave the
>> counter untouched and return an error, we already have too
>> many device operations that might fail more or less silently.
>>
> 
> This can be done.

Thanks.
