From: Ben Greear <greearb@candelatech.com>
Subject: Re: Buggy rhashtable walking
Date: Fri, 05 Aug 2016 04:46:43 -0700
Message-ID: <57A47CA3.4010101@candelatech.com>
References: <20160804071846.GA773@gondor.apana.org.au> <20160804074546.GA996@gondor.apana.org.au> <1470377813.2977.14.camel@sipsolutions.net>	 <20160805104858.GA9297@gondor.apana.org.au> <1470394233.2977.37.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
	tom@herbertland.com
To: Johannes Berg <johannes@sipsolutions.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:35788 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759624AbcHELqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2016 07:46:45 -0400
In-Reply-To: <1470394233.2977.37.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/05/2016 03:50 AM, Johannes Berg wrote:
> On Fri, 2016-08-05 at 18:48 +0800, Herbert Xu wrote:
>> On Fri, Aug 05, 2016 at 08:16:53AM +0200, Johannes Berg wrote:
>>>
>>> Hm. Would you rather allocate a separate head entry for the
>>> hashtable,
>>> or chain the entries?
>>
>> My plan is to build support for this directly into rhashtable.
>> So I'm adding a struct rhlist_head that would be used in place
>> of rhash_head for these cases and it'll carry an extra pointer
>> for the list of identical entries.
>>
>> I will then add an additional layer of insert/lookup interfaces
>> for rhlist_head.

Herbert, thank you for fixing this!

It would not be fun to have to revert to the old way of hashing
stations in mac80211...

I'll be happy to test the patches when you have them ready.

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
