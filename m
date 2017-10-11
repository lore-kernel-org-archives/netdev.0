From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next 0/7] Rewrite some existing functionality
Date: Wed, 11 Oct 2017 17:11:49 -0600
Message-ID: <7fbc0342ced14840973b1e054852fea2@codeaurora.org>
References: <1507695456-17051-1-git-send-email-subashab@codeaurora.org>
 <20171011.152259.969926721717992984.davem@davemloft.net>
 <20171011.152518.927596165753645888.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:34278 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751701AbdJKXLu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 19:11:50 -0400
In-Reply-To: <20171011.152518.927596165753645888.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-10-11 16:25, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 11 Oct 2017 15:22:59 -0700 (PDT)
> 
>> From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
>> Date: Tue, 10 Oct 2017 22:17:29 -0600
>> 
>>> This series fixes some of the broken rmnet functionality.
>>> Bridge mode is re-written and made useable and the muxed_ep is 
>>> converted to hlist.
>>> 
>>> Patches 1-5 are cleanups in preparation for these changes.
>>> Patch 6 does the hlist conversion.
>>> Patch 7 has the implementation of the rmnet bridge mode.
>> 
>> Series applied, thank you.
> 
> Actually, I reverted:
> 
> drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c: In function
> ‘rmnet_rx_handler’:
> drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c:174:6: warning:
> ‘rc’ may be used uninitialized in this function
> [-Wmaybe-uninitialized]
>   int rc;
>       ^~
> 
> Also, the indentation of the switch statement is wrong, the break
> statements need to be indented the same as the rest of the code
> in their switch statements.

Hi David

I'll fix this and upload v2.
Somehow my compiler didnt throw this warning even though i have -Wall 
set.

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
a Linux Foundation Collaborative Project
