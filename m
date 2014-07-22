From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] ethernet: realtek: use module_pci_driver
Date: Tue, 22 Jul 2014 20:33:49 +0530
Message-ID: <53CE7D55.2090404@gmail.com>
References: <1406013622-27869-1-git-send-email-varkabhadram@gmail.com> <1406013622-27869-2-git-send-email-varkabhadram@gmail.com> <53CE777B.3080301@cogentembedded.com> <53CE789E.5070302@gmail.com> <53CE7CC5.2070809@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:39416 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752751AbaGVPDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 11:03:53 -0400
Received: by mail-pa0-f52.google.com with SMTP id bj1so12237909pad.39
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 08:03:53 -0700 (PDT)
In-Reply-To: <53CE7CC5.2070809@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 22 July 2014 08:31 PM, Sergei Shtylyov wrote:
> On 07/22/2014 06:43 PM, Varka Bhadram wrote:
>
>>>> From: Varka Bhadram <varkab@cdac.in>
>
>>>> This patch converts to use the macro module_pci_driver, which makes
>>>> the code smaller and simpler.
>
>>>> Signed-off-by: Varka Bhadram <varkab@cdac.in>
>>>> ---
>>>>   drivers/net/ethernet/realtek/8139cp.c |   22 ++--------------------
>>>>   1 file changed, 2 insertions(+), 20 deletions(-)
>
>>>> diff --git a/drivers/net/ethernet/realtek/8139cp.c
>>>> b/drivers/net/ethernet/realtek/8139cp.c
>>>> index 2bc728e..9fb68b9 100644
>>>> --- a/drivers/net/ethernet/realtek/8139cp.c
>>>> +++ b/drivers/net/ethernet/realtek/8139cp.c
>>>> @@ -1887,11 +1887,7 @@ static int cp_init_one (struct pci_dev 
>>>> *pdev, const
>>>> struct pci_device_id *ent)
>>>>       resource_size_t pciaddr;
>>>>       unsigned int addr_len, i, pci_using_dac;
>>>>
>>>> -#ifndef MODULE
>>>> -    static int version_printed;
>>>> -    if (version_printed++ == 0)
>>>> -        pr_info("%s", version);
>>>> -#endif
>>>> +    pr_info("%s", version);
>
>>>    Use pr_info_once().
>
>>> WBR, Sergei
>
>> I am going to utilize the removed code by removing the #ifndef MODULE...
>
>> It will be like:
>>
>>      static int version_printed;
>>
>>      if (version_printed++ == 0)
>>          pr_info("%s", version);
>
>    pr_info_once() is much shorter and the effect is the same.
>
> WBR, Sergei
>
Thanks for your suggestion. I will do this in next version.


-- 
Regards,
Varka Bhadram
