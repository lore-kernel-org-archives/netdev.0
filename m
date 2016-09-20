From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] mlx4 misc fixes and improvements
Date: Tue, 20 Sep 2016 05:02:17 -0400 (EDT)
Message-ID: <20160920.050217.1968385859186341217.davem@davemloft.net>
References: <20160918.220046.1374771296032853447.davem@davemloft.net>
        <CAJ3xEMi-4nNxDf3pBrDwenN50BTFtTT0+cMF62BMHYPK9WvZrg@mail.gmail.com>
        <6bcc5e49-2204-242a-c939-2352d0646f87@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerlitz.or@gmail.com, netdev@vger.kernel.org, eranbe@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45492 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932165AbcITJCU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 05:02:20 -0400
In-Reply-To: <6bcc5e49-2204-242a-c939-2352d0646f87@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Tue, 20 Sep 2016 11:50:17 +0300

>> So when we're pretty late in the 4.8-rc cycle, a fix for a problem
>> which was not introduced in 4.8-rc1 was targeted to net-next (4.9) and
>> not net.
>>
>> This indeed creates a small mess when the fix needs to go to -stable
>> as well.
 ...
> I see that the series status is 'Changes requested'.
> I agree with Or. If possible, please take the series, and we will
> issue a request to push into -stable in the future.
> Anyway, I can also do a re-submission if you prefer. Just let me know.

Either the bug exists in pre-net trees and needs to go to -stable, or
it does not.

If it does, you submit the change targetting 'net'.

This whole mess occurred because you tried to combine changes
inappropriate for 'net' with the bug fix.

Instead of fixing the issue properly, by removing the cleanups
and inappropriate changes, you tried to target 'net-next' instead.

That's why this mess exists.

Please send the change properly, targetting 'net', and not
alongside changes which are inappropriate to 'net'.

There is no other acceptable way to resolve this problem.

Thank you.
