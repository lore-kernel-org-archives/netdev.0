From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net:phy fix driver reference count error when attach and
 detach phy device
Date: Thu, 5 Jan 2017 20:48:02 -0800
Message-ID: <9086cf5e-18c4-0e17-4f0e-6a630cf1c7d7@gmail.com>
References: <1480501378-10172-1-git-send-email-maowenan@huawei.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0232613@AcuExch.aculab.com>
 <0cef0798-7b0d-734d-17a3-bebffe6206c7@huawei.com>
 <7902ba31-de5d-27cf-f631-4a88a78b246f@huawei.com>
 <c4fce3bf-4105-c7f2-fc67-be4316a2004a@gmail.com>
 <F95AC9340317A84688A5F0DF0246F3F201524E04@szxeml504-mbs.china.huawei.com>
 <70502429-5edf-924f-6e48-89340620ae6f@gmail.com>
 <cbd390e3-666b-dcc3-2ff3-18fa75549167@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: maowenan <maowenan@huawei.com>,
        David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Dingtianhong <dingtianhong@huawei.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34256 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754408AbdAFEsE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 23:48:04 -0500
Received: by mail-oi0-f65.google.com with SMTP id 3so53077480oih.1
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 20:48:04 -0800 (PST)
In-Reply-To: <cbd390e3-666b-dcc3-2ff3-18fa75549167@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/05/17 à 19:39, maowenan a écrit :
> 
> 
> On 2017/1/6 11:21, Florian Fainelli wrote:
>> +Andrew,
>>
>> Le 01/05/17 à 18:29, maowenan a écrit :
>>>>> @Florian Fainelli, what's your comments about this patch?
>>>>
>>>> I am trying to reproduce what you are seeing, but at first glance is looks like an
>>>> appropriate solution to me. Do you mind giving me a couple more days?
>>>>
>>>> Thanks!
>>>> --
>>>> Florian
>>>
>>> Hi Florian, 
>>>   Do you have any update about this patch?
>>
>> Your patch is not complete, there are now MDIO device (which PHY devices
>> are a superset of) that would also need a similar fix.
>>
> ok, is there any patch to fix MDIO yet?  if not, i will verify it and give a fix patch?
> 

No, there is not a patch yet, your approach looks okay, but need to be
made general and cover MDIO devices as well.

Thank you!
-- 
Florian
