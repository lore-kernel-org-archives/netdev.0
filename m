From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 05/12] net: Create and use new helper
 xfrm_dst_child().
Date: Thu, 26 Oct 2017 09:12:46 +0900 (KST)
Message-ID: <20171026.091246.81914712364337213.davem@davemloft.net>
References: <20171025.230325.1201318483362616226.davem@davemloft.net>
        <CAP-MU4M7qeOdSDorZvFyH9BxvXZEFupftmKnV+pWpMQEyLpwHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shannon.lee.nelson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55428 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751892AbdJZAMt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 20:12:49 -0400
In-Reply-To: <CAP-MU4M7qeOdSDorZvFyH9BxvXZEFupftmKnV+pWpMQEyLpwHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.lee.nelson@gmail.com>
Date: Wed, 25 Oct 2017 08:56:06 -0700

> On Wed, Oct 25, 2017 at 7:03 AM, David Miller <davem@davemloft.net> wrote:
>>
>>
>> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
>> index f002a2c5e33c..4fa951112873 100644
>> --- a/include/net/xfrm.h
>> +++ b/include/net/xfrm.h
>> @@ -994,6 +994,15 @@ struct xfrm_dst {
>>  };
>>
>>  #ifdef CONFIG_XFRM
> 
> Perhaps the new xfrm_dst_child() code needs to go before this #ifdef?
> sln

Yeah, if you look, that's what ends up happening in a later patch.

Thanks for the feedback.
