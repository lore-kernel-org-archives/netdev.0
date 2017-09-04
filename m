From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 0/4] net: dsa: Allow switch drivers to
 indicate number of TX queues
Date: Sun, 3 Sep 2017 20:27:31 -0700
Message-ID: <4ec705e2-796d-ee74-e071-361918336e9e@gmail.com>
References: <20170902180609.23122-1-f.fainelli@gmail.com>
 <20170903.202009.2104340600797726296.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, jiri@resnulli.us,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:37089 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753124AbdIDD1e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 23:27:34 -0400
Received: by mail-io0-f171.google.com with SMTP id 62so7422011iok.4
        for <netdev@vger.kernel.org>; Sun, 03 Sep 2017 20:27:34 -0700 (PDT)
In-Reply-To: <20170903.202009.2104340600797726296.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/03/17 à 20:20, David Miller a écrit :
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Sat,  2 Sep 2017 11:06:05 -0700
> 
>> This patch series extracts the parts of the patch set that are likely not to be
>> controversial and actually bringing multi-queue support to DSA-created network
>> devices.
>>
>> With these patches, we can now use sch_multiq as documented under
>> Documentation/networking/multique.txt and let applications dedice the switch
>> port output queue they want to use. Currently only Broadcom tags utilize that
>> information.
>>
>> Changes in v2:
>> - use a proper define for the number of TX queues in bcm_sf2.c (Andrew)
> 
> Hello Florian.
> 
> For some reason this series didn't make it completely into patchwork, I only
> see patch #1 there.
> 
> Can you try submitting again?  If it doesn't work this time I'll just apply
> it by hand from my inbox.

No problem, I just resent this patch series, thanks for the heads-up.
-- 
Florian
