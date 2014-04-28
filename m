From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/9 v2] net: Add sysctl to trust checksum_complete
Date: Mon, 28 Apr 2014 00:15:52 -0400 (EDT)
Message-ID: <20140428.001552.1083601553706782584.davem@davemloft.net>
References: <CA+mtBx-hAJDvXigrw1w3S1OBhmG4iiZvBBKNtCXZMt+8ZzFduw@mail.gmail.com>
	<20140427.233204.1660487737838648405.davem@davemloft.net>
	<CA+mtBx9w6-id5NDuP31yMrhO9Ho8TM2O5oGfneXiT_f+G+Xvag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36497 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754128AbaD1EPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 00:15:55 -0400
In-Reply-To: <CA+mtBx9w6-id5NDuP31yMrhO9Ho8TM2O5oGfneXiT_f+G+Xvag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 27 Apr 2014 21:07:24 -0700

>> If we do anything, we should do it consistently and not just for one
>> specific checksum delivery type.
>>
>> So if we add a sysctl, it should revalidate the checksum in software
>> for all checksum offload variants, and such a sysctl should be off by
>> default.
> 
> Okay, but I would want to add a new checksum type to distinguish
> checksum_complete that was done in software as opposed to one received
> from a device.

I don't think it's wise to keep CHECKSUM_COMPLETE once you've software
verified it.

If anything, you should at that point treat it as we would have treated
it were it marked CHECKSUM_NONE.

Therefore I see no reason for a new checksum type.

Please repost your series if you want me to consider it with this patch
removed, rather than just saying "apply the series without patch X".

Thanks.
