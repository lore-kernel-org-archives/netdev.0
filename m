From: David Miller <davem@davemloft.net>
Subject: Re: [linux-next:master 1436/1582]
 drivers/net/ethernet/smsc/smc91x.c:2378:6: error: implicit declaration of
 function 'machine_is_assabet'
Date: Wed, 19 Oct 2016 16:12:06 -0400 (EDT)
Message-ID: <20161019.161206.1749616830232202176.davem@davemloft.net>
References: <201610200342.Wv4wShnU%fengguang.wu@intel.com>
        <87funs3ycx.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de
To: robert.jarzmik@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60536 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752006AbcJSUMO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 16:12:14 -0400
In-Reply-To: <87funs3ycx.fsf@belgarion.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Jarzmik <robert.jarzmik@free.fr>
Date: Wed, 19 Oct 2016 21:58:06 +0200

> Hi David,
> 
> Here is a little mess I created with my former serie :
>>    drivers/net/ethernet/smsc/smc91x.c: In function 'smc_drv_probe':
>>>> drivers/net/ethernet/smsc/smc91x.c:2378:6: error: implicit declaration of function 'machine_is_assabet' [-Werror=implicit-function-declaration]
>>      if (machine_is_assabet() && machine_has_neponset())
>>          ^~~~~~~~~~~~~~~~~~
>>    cc1: some warnings being treated as errors
>>
>> vim +/machine_is_assabet +2378 drivers/net/ethernet/smsc/smc91x.c
> 
> The mess comes from the patch "net: smc91x: isolate u16 writes alignment
> workaround", where I though I had removed all "machine_is_*()" calls, and I
> didn't notice the machine_is_assabet() one.
> 
> The fix is to re-add the removed include in the wrong chunk in [1].
> 
> Now do you want :
>  - another apart patch to fix the faulty one
>  - a "fixup!" patch to fixup the commit in your next tree
>  - or anything else

Please send me a fixup follow-on patch.

If changes are in my tree, they are part of the permanent record
and won't be rebased out.
