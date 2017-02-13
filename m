From: Dongpo Li <lidongpo@hisilicon.com>
Subject: Re: net: hix5hd2_gmac uninitialized net_device
Date: Mon, 13 Feb 2017 09:25:38 +0800
Message-ID: <58A10B12.8050400@hisilicon.com>
References: <20170210074118.vchxsn7fag6tlsmg@tha-monstah.mydomain>
 <20170210074544.eoabpjf522pmwoui@tha-monstah.mydomain>
 <589D942F.7070700@hisilicon.com>
 <20170211005132.xdk2d7etb732scqo@tha-monstah.mydomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>
To: Marty Plummer <netz.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:64074 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751193AbdBMBZt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 20:25:49 -0500
In-Reply-To: <20170211005132.xdk2d7etb732scqo@tha-monstah.mydomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/2/11 8:51, Marty Plummer wrote:
> On Fri, Feb 10, 2017 at 06:21:35PM +0800, Dongpo Li wrote:
>> I think the error "No irq resource" happened for some other reason, has no relation with
>> the info "(unnamed net_device) (uninitialized):".
>> You can add more debug info to find bug.
> Do you have any particular suggestions as to what to check out, or is
> this just a general 'debug more' instruction?
I haven't encountered such a problem. So it needs you to debug what happens.

>> Yes, I agree with you that the ndev has not been initialized completely,
>> because the function "register_netdev" has not been called yet.
>> It's better to use the "dev_err" to replace the "netdev_err".
>>
> Ah, I see. So, prior to line 1266's call to register_netdev, it will
> always be uninitialized and unnamed, regardless of what is or isn't
> right elsewhere. Good to know. So, I could replace these netdev_err
> with dev_err for now, up until that point, so I can get a bit more info,
> yes?
Yes.


    Regards,
    Dongpo

.
