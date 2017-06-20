From: Serhey Popovych <serhe.popovych@gmail.com>
Subject: Re: [PATCH] loopback: Force LOOPBACK_IFINDEX for registration
Date: Tue, 20 Jun 2017 13:32:20 +0300
Message-ID: <60e546b5-2548-5eef-ebc6-4cf0ca44da27@gmail.com>
References: <1497615003-24762-1-git-send-email-serhe.popovych@gmail.com>
 <20170619.144123.2070662074449196481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34435 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751102AbdFTKcX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 06:32:23 -0400
Received: by mail-wm0-f68.google.com with SMTP id f134so4477084wme.1
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 03:32:23 -0700 (PDT)
In-Reply-To: <20170619.144123.2070662074449196481.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: Serhey Popovych <serhe.popovych@gmail.com>
> Date: Fri, 16 Jun 2017 15:10:03 +0300
> 
>> Now with commit 9c7dafb (net: Allow to create links with
>> given ifindex) support registration of network devices
>> with specific ifindex is added.
>>
>> We can force loopback network device index before call to
>> register_netdev() to ensure we always configure it with
>> LOOPBACK_IFINDEX.
>>
>> Kill BUG_ON() since system can continue without network
>> namespace failed in loopback init path, unless it is
>> init_net namespace where we panic() anyway.
>>
>> Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>
> 
> Is the BUG_ON() triggering, if so why?
> 
> It looks to me that unless there is a bug, this assignment
> is unnecessary.
> 
Okay, get your position, thanks!

-- 
Thanks, Serhey
