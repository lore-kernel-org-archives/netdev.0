From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 20/52] net: fealnx: remove unnecessary pci_set_drvdata()
Date: Thu, 12 Sep 2013 21:11:42 +0400
Message-ID: <5231F5CE.8000406@cogentembedded.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com> <005e01ceaec2$23e32420$6ba96c60$%han@samsung.com> <5230B435.2050908@cogentembedded.com> <000e01ceaf4c$90cde130$b269a390$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:60228 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754337Ab3ILRLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 13:11:39 -0400
Received: by mail-la0-f54.google.com with SMTP id ea20so79254lab.27
        for <netdev@vger.kernel.org>; Thu, 12 Sep 2013 10:11:38 -0700 (PDT)
In-Reply-To: <000e01ceaf4c$90cde130$b269a390$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/12/2013 04:11 AM, Jingoo Han wrote:

>>> The driver core clears the driver data to NULL after device_release
>>> or on probe failure. Thus, it is not needed to manually clear the
>>> device driver data to NULL.

>>> Signed-off-by: Jingoo Han <jg1.han@samsung.com>
>>> ---
>>>    drivers/net/ethernet/fealnx.c |    4 ++--
>>>    1 file changed, 2 insertions(+), 2 deletions(-)

>>> diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
>>> index c706b7a..99194d1 100644
>>> --- a/drivers/net/ethernet/fealnx.c
>>> +++ b/drivers/net/ethernet/fealnx.c
>>> @@ -699,9 +699,9 @@ static void fealnx_remove_one(struct pci_dev *pdev)
>>>    		pci_iounmap(pdev, np->mem);
>>>    		free_netdev(dev);
>>>    		pci_release_regions(pdev);
>>> -		pci_set_drvdata(pdev, NULL);
>>> -	} else
>>> +	} else {
>>>    		printk(KERN_ERR "fealnx: remove for unknown device\n");
>>> +	}

>>      No "drove-by" coding style fixes, please.

> Hi Sergei,

> Sorry, but I just want to know the reason. :-)
> Would you let know the reason not to add coding style fixes?

    This change doesn't get covered by the patch subject/changelog. Even if 
you're doing it, it should preferably be done in a separate patch and at the 
very least documented in the changelog.

> Thank you.

    Not at all.

> Best regards,
> Jingoo Han

WBR, Sergei
