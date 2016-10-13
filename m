From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qed: Fix to use list_for_each_entry_safe() when delete
 items
Date: Thu, 13 Oct 2016 10:40:49 -0400 (EDT)
Message-ID: <20161013.104049.1688046385759378480.davem@davemloft.net>
References: <1476019942-6837-1-git-send-email-weiyj.lk@gmail.com>
        <20161013.094725.657883863089600176.davem@davemloft.net>
        <BL2PR07MB2306E19AD9C9FE46992E12A78DDC0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: weiyj.lk@gmail.com, Ariel.Elior@qlogic.com, weiyongjun1@huawei.com,
        netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33606 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751335AbcJMOrw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 10:47:52 -0400
In-Reply-To: <BL2PR07MB2306E19AD9C9FE46992E12A78DDC0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Date: Thu, 13 Oct 2016 14:14:40 +0000

>> > Since we will remove items off the list using list_del() we need to
>> > use a safe version of the list_for_each_entry() macro aptly named
>> > list_for_each_entry_safe().
>> >
>> > Fixes: 0a7fb11c23c0 ("qed: Add Light L2 support")
>> > Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
>> 
>> Can the QED maintainers please review this simple fix?
>> 
>> In my opinion 4 days is sufficient time in which to expect a reasonable review to
>> occur, let me know if you disagree. :-)
> 
> Sorry about that; The high holy days are killing our productivity. :-(
> I did ACK v1, though [and v2 was purely semantic change].

Indeed, I just noticed that, thanks!
