From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: Re: [net, 6/6] net: korina: version bump
Date: Sun, 22 Jan 2017 14:10:41 +0200
Message-ID: <CACiydbKPNZyN+_+TDkHsbg0uGR51iDcqSTAQUMKyVCJ+u9wL7w@mail.gmail.com>
References: <1484674393-22515-1-git-send-email-roman@advem.lv>
 <e607e3a1-8227-7768-2234-6a3340f4a368@nbd.name> <CACiydbLu+sKihjKsGVV5kiruSAEwcpJFsUOyASxnBd6=5+xddQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Felix Fietkau <nbd@nbd.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:33475 "EHLO
        mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750770AbdAVMKm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 07:10:42 -0500
Received: by mail-vk0-f65.google.com with SMTP id t8so9187855vke.0
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 04:10:42 -0800 (PST)
In-Reply-To: <CACiydbLu+sKihjKsGVV5kiruSAEwcpJFsUOyASxnBd6=5+xddQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17 January 2017 at 21:19, Roman Yeryomin <leroi.lists@gmail.com> wrote:
> On 17 January 2017 at 20:55, Felix Fietkau <nbd@nbd.name> wrote:
>> On 2017-01-17 18:33, Roman Yeryomin wrote:
>>> Signed-off-by: Roman Yeryomin <roman@advem.lv>
>>> ---
>>>  drivers/net/ethernet/korina.c | 4 ++--
>>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
>>> index 83c994f..c8fed01 100644
>>> --- a/drivers/net/ethernet/korina.c
>>> +++ b/drivers/net/ethernet/korina.c
>>> @@ -66,8 +66,8 @@
>>>  #include <asm/mach-rc32434/dma_v.h>
>>>
>>>  #define DRV_NAME     "korina"
>>> -#define DRV_VERSION  "0.10"
>>> -#define DRV_RELDATE  "04Mar2008"
>>> +#define DRV_VERSION  "0.20"
>>> +#define DRV_RELDATE  "15Jan2017"
>> I think it would make more sense to remove this version instead of
>> bumping it. Individual driver versions are rather pointless, the kernel
>> version is more meaningful anyway.
>
> OK, makes sense

Actually, after thinking a bit more about this, not really...
How about ethtool, which uses driver name and version?
I see most ethernet drivers define some version. And it's pretty
useful, when using backports.
IMO, it should be kept and bumped.

Regards,
Roman
