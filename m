From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/5] pktgen IPsec support
Date: Tue, 10 Dec 2013 00:49:46 -0500 (EST)
Message-ID: <20131210.004946.994121183512258929.davem@davemloft.net>
References: <52A6763C.4050101@windriver.com>
	<20131209.210916.1684103670392129860.davem@davemloft.net>
	<52A67C2B.2030508@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46375 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705Ab3LJFtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 00:49:49 -0500
In-Reply-To: <52A67C2B.2030508@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Tue, 10 Dec 2013 10:27:55 +0800

> 
> 
> On 2013年12月10日 10:09, David Miller wrote:
>> From: Fan Du<fan.du@windriver.com>
>> Date: Tue, 10 Dec 2013 10:02:36 +0800
>>
>>> Can I just reply to custom "Yes, wrong checksum value and
>>> non-decrypted packet
>>> is not big deal when your peer host receiving them"?
>>
>> It's a packet spamming tool, take that into consideration.
>> Regardless of what you may think, it is simply the case that you can't
>> just remove something because you perceive it as not useful to anyone.
>>
>> This goes doubly for something exposed to users for a decade.
>>
>> Please change your patch series to retain the feature.
> 
> I will restore "wrong checksum/len packet" behavior as a default
> behavior,
> As a matter of fact this has nothing to do with Patch1/5 which removes
> codes.
> And then making enhanced feature as optional for user who expects good
> format packet
> 
> Is this fine for you, finally?

Sure.
