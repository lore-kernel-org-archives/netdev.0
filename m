From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: add a fib_type to fib_info
Date: Thu, 04 Oct 2012 14:14:14 -0400 (EDT)
Message-ID: <20121004.141414.1035765605088298539.davem@davemloft.net>
References: <1349349926.16011.48.camel@edumazet-glaptop>
	<506D8A4F.3020008@googlemail.com>
	<1349357528.16011.55.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chris2553@googlemail.com, netdev@vger.kernel.org, gpiez@web.de,
	davej@redhat.com, ja@ssi.bg
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858Ab2JDSOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 14:14:16 -0400
In-Reply-To: <1349357528.16011.55.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 04 Oct 2012 15:32:08 +0200

> On Thu, 2012-10-04 at 14:08 +0100, Chris Clayton wrote:
> 
>> I've tested 3.6.0 with this patch applied and networking in a WinXP KVM 
>> client is now working fine. The patch applies cleanly to 3.6.0, so I 
>> assume the patch will be forwarded to stable in due course.
>> 
>> Tested-by: Chris Clayton <chris2553@googlemail.com>
> 
> Thanks for testing.

Applied and queued up for -stable, thanks everyone.

Note that this change means we can completely remove the type fields
from fib_alias and fib_result when net-next opens up, as the value can
be fetched from the fib_info directly now.
