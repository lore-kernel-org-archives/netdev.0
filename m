From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: mvpp2: do not bypass the mvpp22_port_mii_set
 function
Date: Tue, 6 Jun 2017 07:24:35 -0700
Message-ID: <9ef70606-0918-fc4f-535b-dd1fc3475cb6@gmail.com>
References: <20170606133615.20747-1-antoine.tenart@free-electrons.com>
 <20170606154535.3e87bafb@free-electrons.com>
 <20170606135148.GA22618@kwain.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@armlinux.org.uk,
        gregory.clement@free-electrons.com, mw@semihalf.com,
        davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f196.google.com ([74.125.82.196]:33584 "EHLO
        mail-ot0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751587AbdFFOYk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 10:24:40 -0400
Received: by mail-ot0-f196.google.com with SMTP id k4so2165066otd.0
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 07:24:39 -0700 (PDT)
In-Reply-To: <20170606135148.GA22618@kwain.lan>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/2017 06:51 AM, Antoine Tenart wrote:
> Hello Thomas,
> 
> On Tue, Jun 06, 2017 at 03:45:35PM +0200, Thomas Petazzoni wrote:
>> On Tue,  6 Jun 2017 15:36:15 +0200, Antoine Tenart wrote:
>>> The mvpp22_port_mii_set() function was added by 2697582144dd, but the
>>> function directly returns without doing anything. This return was used
>>> when debugging and wasn't removed before sending the patch. Fix this.
>>>
>>> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
>>
>> Please add:
>>
>> Fixes: 2697582144dd ("net: mvpp2: handle misc PPv2.1/PPv2.2 differences")
>>
>> with this:
>>
>> Acked-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> 
> OK, will do.
> 
>> I am wondering if we shouldn't Cc: stable as well. I don't think we
>> have seen issues on our side because U-Boot does the necessary
>> initialization, but people using other bootloaders might have issues.
> 
> Yes, that might be safer to cc stable. I'll do this as well.

David queues network patches for stable provided that you submit those
against his "net" tree [1] and there is an appropriate Fixes tag (which
Thomas provided).

[1]:
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/networking/netdev-FAQ.txt#n114
-- 
Florian
