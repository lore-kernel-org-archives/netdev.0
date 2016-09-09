From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH next 3/3] ipvlan: Introduce l3s mode
Date: Fri, 9 Sep 2016 15:46:22 -0700
Message-ID: <CAF2d9jj35YjaAJ4ziUSBFdgakhMY3o8M=VHU4bOfzWA=e0k_0Q@mail.gmail.com>
References: <1473458010-18571-1-git-send-email-mahesh@bandewar.net> <ddb5c5e8-6656-754a-8178-09096a2d333e@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f174.google.com ([209.85.161.174]:33307 "EHLO
        mail-yw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751120AbcIIWqs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 18:46:48 -0400
Received: by mail-yw0-f174.google.com with SMTP id l8so55766052ywb.0
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 15:46:47 -0700 (PDT)
In-Reply-To: <ddb5c5e8-6656-754a-8178-09096a2d333e@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 9, 2016 at 3:26 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 9/9/16 3:53 PM, Mahesh Bandewar wrote:
>> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
>> index 0c5415b05ea9..95edd1737ab5 100644
>> --- a/drivers/net/Kconfig
>> +++ b/drivers/net/Kconfig
>> @@ -149,6 +149,7 @@ config IPVLAN
>>      tristate "IP-VLAN support"
>>      depends on INET
>>      depends on IPV6
>> +    select NET_L3_MASTER_DEV
>
> depends on instead of select?

The kbuild/kconfig-language.txt suggests that for "depends on" the
option _must_ be selected otherwise menuconfig wont even present the
dependent option while select positively sets the option.

INET and IPv6 are well understood and almost all configs select that.
L3_MASTER is very new and not well understood so chances of someone
_not_ putting them (IPvlan and L3_MASTER) in same context are very
high.
