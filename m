From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v3 8/8] xdp: Cleanup after API changes
Date: Tue, 21 Feb 2017 17:14:47 -0500 (EST)
Message-ID: <20170221.171447.918145585590016034.davem@davemloft.net>
References: <20170221193417.3641224-9-tom@herbertland.com>
        <20170221.160618.716814569978889472.davem@davemloft.net>
        <CALx6S372n+CNi7Pis-Z-2gGzOOPDOreLcdJVyX+AMDonRnJr5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33772 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751334AbdBUWOv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 17:14:51 -0500
In-Reply-To: <CALx6S372n+CNi7Pis-Z-2gGzOOPDOreLcdJVyX+AMDonRnJr5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 21 Feb 2017 13:24:43 -0800

> On Tue, Feb 21, 2017 at 1:06 PM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <tom@herbertland.com>
>> Date: Tue, 21 Feb 2017 11:34:17 -0800
>>
>>>   - Change trace_xdp_hook_exception to trace_xdp_exception
>>
>> Just give it this final name in patch #1 where you introduce it.
> 
> That will break compilation of the intervening patches. That is okay?

The trace hook doesn't even exist until patch #1, so yes if you name it
properly from the start any references you have to it within followon
patches need to be adjusted as well.
