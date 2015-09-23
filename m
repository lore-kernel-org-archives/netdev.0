From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6 Use get_hash_from_flowi6 for rt6 hash
Date: Wed, 23 Sep 2015 14:57:30 -0700 (PDT)
Message-ID: <20150923.145730.671266108610739603.davem@davemloft.net>
References: <1443042815-3458631-1-git-send-email-tom@herbertland.com>
	<20150923.142138.873048869450376623.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, pch@ordbogen.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45887 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753500AbbIWV5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 17:57:31 -0400
In-Reply-To: <20150923.142138.873048869450376623.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 23 Sep 2015 14:21:38 -0700 (PDT)

> From: Tom Herbert <tom@herbertland.com>
> Date: Wed, 23 Sep 2015 14:13:35 -0700
> 
>> In rt6_info_hash_nhsfn replace the custom hashing over flowi6 that is
>> using xor with a call to common function get_hash_from_flowi6.
>> 
>> Signed-off-by: Tom Herbert <tom@herbertland.com>
> 
> Applied, thanks.

Tom, I just so happened to look over the call paths that lead to this
function and the flowi6 ports aren't filled in much of the time.

I know your patch doesn't change things one way or the other in this
area, but I thought I'd bring it up nonetheless.
