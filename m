From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Fix IFE meta modules loading
Date: Thu, 12 Oct 2017 22:13:50 -0700 (PDT)
Message-ID: <20171012.221350.700540002817151386.davem@davemloft.net>
References: <1507733430-17860-1-git-send-email-mrv@mojatatu.com>
        <20171012.122318.1151617277989957064.davem@davemloft.net>
        <85lgkgw19o.fsf@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: mrv@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35034 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753294AbdJMFNw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 01:13:52 -0400
In-Reply-To: <85lgkgw19o.fsf@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Mashak <mrv@mojatatu.com>
Date: Thu, 12 Oct 2017 16:37:39 -0400

> David Miller <davem@davemloft.net> writes:
> 
>> From: Roman Mashak <mrv@mojatatu.com>
>> Date: Wed, 11 Oct 2017 10:50:28 -0400
>>
>>> Adjust module alias names of IFE meta modules and fix the bug that
>>> prevented auto-loading IFE modules in run-time.
>>
>> Anyone using the existing alises will be broken by these changes
>> no?
> 
> Actually aliases never worked, the bug existed since the day act_meta_*
> modules have been introduced. I suspect everyone compiles them in-kernel
> rather then as modules.

Fair enough, series applied, thanks for explaining.
