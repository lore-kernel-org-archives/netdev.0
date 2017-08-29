From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/4] Endian fixes for SYSTEMPORT/SF2/MDIO
Date: Tue, 29 Aug 2017 15:08:00 -0700
Message-ID: <cf41703a-67e4-609b-e7ec-bd962ffec6c7@gmail.com>
References: <1504031985-52808-1-git-send-email-f.fainelli@gmail.com>
 <20170829.144254.740239595444825239.davem@davemloft.net>
 <d8ae99de-398d-f314-309f-50c36df9240a@gmail.com>
 <20170829.145203.2052260546778215324.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, opendmb@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:32955 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751758AbdH2WIJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 18:08:09 -0400
Received: by mail-qk0-f196.google.com with SMTP id k126so647094qkb.0
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 15:08:09 -0700 (PDT)
In-Reply-To: <20170829.145203.2052260546778215324.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2017 02:52 PM, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Tue, 29 Aug 2017 14:45:30 -0700
> 
>> On 08/29/2017 02:42 PM, David Miller wrote:
>>> From: Florian Fainelli <f.fainelli@gmail.com>
>>> Date: Tue, 29 Aug 2017 11:39:41 -0700
>>>
>>>> While trying an ARM BE kernel for kinks, the 3 drivers below started not
>>>> working and the reasons why became pretty obvious because the register space
>>>> remains LE (hardwired), except for Broadcom MIPS where it follows the CPU's
>>>> native endian (let's call that a feature).
>>>
>>> Series applied, thanks Florian.
>>
>> If you have not pushed yet, seems like not, can you check you applied v2
>> of this patch series, in particular this patch:
>>
>> http://patchwork.ozlabs.org/patch/807296/
> 
> If you didn't keep messing with the patchwork state of patches in my
> queue this confusion would not have happened.
> 
> I did happen to apply v2, but because of all of the confusion you keep
> creating, I used the header message from v1.
> 
> It's already pushed out so there is nothing we can do about it.
> 

It's all good, thanks! /me goes updating netdev-FAQ.txt to mention not
touching patchwork.
-- 
Florian
