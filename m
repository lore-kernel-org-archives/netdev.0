From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] Deconstruct struct fib_result
Date: Tue, 31 Jul 2012 14:43:46 -0700 (PDT)
Message-ID: <20120731.144346.118118110436079421.davem@davemloft.net>
References: <20120727.211814.1628871775065221675.davem@davemloft.net>
	<CAKgT0UcOn48gVsC37hiNCXCP=FwqKjZnjkLviCOW8TVWGkGGVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754370Ab2GaVnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 17:43:47 -0400
In-Reply-To: <CAKgT0UcOn48gVsC37hiNCXCP=FwqKjZnjkLviCOW8TVWGkGGVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 31 Jul 2012 10:27:40 -0700

> On Fri, Jul 27, 2012 at 9:18 PM, David Miller <davem@davemloft.net> wrote:
>>
>> This patch set tries to move towards reducing struct fib_result down
>> to it's absolute minimum.
>>
>> The eventual idea is to make it so that fib_lookup() simply
>> returns a "struct fib_nh *" and pointer encoded errnos, instead
>> of writing into a complicated structure as the return value on
>> the stack as is done now.
>>
>> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> I tested these patches most of yesterday and I haven't seen any
> issues.  Then again I haven't seen much of an improvement either.
> 
> Tested-by: Alexander Duyck <alexander.h.duyck@intel.com>

Thanks for testing.

I'm putting this patch set to the side until I can find a way
to get past the tclassid barrier and also make it show some
difference performance wise.
