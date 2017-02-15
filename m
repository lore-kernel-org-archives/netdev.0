From: Dongpo Li <lidongpo@hisilicon.com>
Subject: Re: net: hix5hd2_gmac uninitialized net_device
Date: Wed, 15 Feb 2017 14:18:14 +0800
Message-ID: <58A3F2A6.3060609@hisilicon.com>
References: <20170210074118.vchxsn7fag6tlsmg@tha-monstah.mydomain>
 <20170210074544.eoabpjf522pmwoui@tha-monstah.mydomain>
 <589D942F.7070700@hisilicon.com>
 <20170211005132.xdk2d7etb732scqo@tha-monstah.mydomain>
 <58A10B12.8050400@hisilicon.com>
 <20170214235954.xhuikgj4bbfjq7fv@tha-monstah.mydomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>
To: Marty Plummer <netz.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:12507 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750814AbdBOGS1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 01:18:27 -0500
In-Reply-To: <20170214235954.xhuikgj4bbfjq7fv@tha-monstah.mydomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marty,

On 2017/2/15 7:59, Marty Plummer wrote:
> On Mon, Feb 13, 2017 at 09:25:38AM +0800, Dongpo Li wrote:
>>
>>
>> On 2017/2/11 8:51, Marty Plummer wrote:
>>> On Fri, Feb 10, 2017 at 06:21:35PM +0800, Dongpo Li wrote:
>>>> I think the error "No irq resource" happened for some other reason, has no relation with
>>>> the info "(unnamed net_device) (uninitialized):".
>>>> You can add more debug info to find bug.
>>> Do you have any particular suggestions as to what to check out, or is
>>> this just a general 'debug more' instruction?
>> I haven't encountered such a problem. So it needs you to debug what happens.
>>
> Yes, I've figured out the origin here. It was user error, in that I was
> not nesting the device node under the soc node, which had the
> interrupt-parent property. Moving it there fixed that issue.
> 
> In any case, I've ran into another problem. Basic gist is, I was giving
> it a go on my hi3521a board, because reading the registers for that and
> comparing it to the source, I find they are nearly bit-for-bit
> identical, but I suppose there is some tweakage needed to make it work
> 100%.
> 
> What information would it take to have this driver expanded to enable a
> new, similar SoC?

Currently this driver can't support Hi3521a soc because of some new changes.
I don't know what's your purpose to run hix5hd2 driver on Hi3521a, please ask
the man who sells chips to you to raise your requirements.


    Regards,
    Dongpo

.
