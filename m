From: Felix Fietkau <nbd@nbd.name>
Subject: Re: [net, 6/6] net: korina: version bump
Date: Sun, 22 Jan 2017 14:21:47 +0100
Message-ID: <52436caa-bdf5-708a-3a4f-67778e40d501@nbd.name>
References: <1484674393-22515-1-git-send-email-roman@advem.lv>
 <e607e3a1-8227-7768-2234-6a3340f4a368@nbd.name>
 <CACiydbLu+sKihjKsGVV5kiruSAEwcpJFsUOyASxnBd6=5+xddQ@mail.gmail.com>
 <CACiydbKPNZyN+_+TDkHsbg0uGR51iDcqSTAQUMKyVCJ+u9wL7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roman Yeryomin <leroi.lists@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:46757 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751099AbdAVNVt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 22 Jan 2017 08:21:49 -0500
In-Reply-To: <CACiydbKPNZyN+_+TDkHsbg0uGR51iDcqSTAQUMKyVCJ+u9wL7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-01-22 13:10, Roman Yeryomin wrote:
> On 17 January 2017 at 21:19, Roman Yeryomin <leroi.lists@gmail.com> wrote:
>> On 17 January 2017 at 20:55, Felix Fietkau <nbd@nbd.name> wrote:
>>> On 2017-01-17 18:33, Roman Yeryomin wrote:
>>>> Signed-off-by: Roman Yeryomin <roman@advem.lv>
>>>> ---
>>>>  drivers/net/ethernet/korina.c | 4 ++--
>>>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
>>>> index 83c994f..c8fed01 100644
>>>> --- a/drivers/net/ethernet/korina.c
>>>> +++ b/drivers/net/ethernet/korina.c
>>>> @@ -66,8 +66,8 @@
>>>>  #include <asm/mach-rc32434/dma_v.h>
>>>>
>>>>  #define DRV_NAME     "korina"
>>>> -#define DRV_VERSION  "0.10"
>>>> -#define DRV_RELDATE  "04Mar2008"
>>>> +#define DRV_VERSION  "0.20"
>>>> +#define DRV_RELDATE  "15Jan2017"
>>> I think it would make more sense to remove this version instead of
>>> bumping it. Individual driver versions are rather pointless, the kernel
>>> version is more meaningful anyway.
>>
>> OK, makes sense
> 
> Actually, after thinking a bit more about this, not really...
> How about ethtool, which uses driver name and version?
> I see most ethernet drivers define some version. And it's pretty
> useful, when using backports.
> IMO, it should be kept and bumped.
I don't really care, I just wanted to point out that the exact kernel
version is a much more useful indicator, especially since not all patch
submitters do the useless version bump dance.

- Felix
