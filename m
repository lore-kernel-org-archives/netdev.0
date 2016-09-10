From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH next 3/3] ipvlan: Introduce l3s mode
Date: Sat, 10 Sep 2016 10:25:27 -0600
Message-ID: <7c134452-368e-96f9-c0b1-0f6d2e507bc5@cumulusnetworks.com>
References: <1473458010-18571-1-git-send-email-mahesh@bandewar.net>
 <ddb5c5e8-6656-754a-8178-09096a2d333e@cumulusnetworks.com>
 <CAF2d9jj35YjaAJ4ziUSBFdgakhMY3o8M=VHU4bOfzWA=e0k_0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>
To: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS1?=
         =?UTF-8?B?4KS+4KSwKQ==?= <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:32868 "EHLO
        mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755666AbcIJQZ3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2016 12:25:29 -0400
Received: by mail-pa0-f43.google.com with SMTP id cm16so37974176pac.0
        for <netdev@vger.kernel.org>; Sat, 10 Sep 2016 09:25:29 -0700 (PDT)
In-Reply-To: <CAF2d9jj35YjaAJ4ziUSBFdgakhMY3o8M=VHU4bOfzWA=e0k_0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/9/16 4:46 PM, Mahesh Bandewar (महेश बंडेवार) wrote:
> On Fri, Sep 9, 2016 at 3:26 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> On 9/9/16 3:53 PM, Mahesh Bandewar wrote:
>>> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
>>> index 0c5415b05ea9..95edd1737ab5 100644
>>> --- a/drivers/net/Kconfig
>>> +++ b/drivers/net/Kconfig
>>> @@ -149,6 +149,7 @@ config IPVLAN
>>>      tristate "IP-VLAN support"
>>>      depends on INET
>>>      depends on IPV6
>>> +    select NET_L3_MASTER_DEV
>>
>> depends on instead of select?
> 
> The kbuild/kconfig-language.txt suggests that for "depends on" the
> option _must_ be selected otherwise menuconfig wont even present the
> dependent option while select positively sets the option.

understood. VRF driver uses 'depends on'
