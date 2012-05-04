From: Karsten Keil <kkeil@linux-pingi.de>
Subject: Re: [PATCHv3 6/6] mISDN: Help to identify the card
Date: Fri, 04 May 2012 17:58:58 +0200
Message-ID: <4FA3FCC2.1080702@linux-pingi.de>
References: <1336140935-25830-1-git-send-email-kkeil@linux-pingi.de> <1336140935-25830-7-git-send-email-kkeil@linux-pingi.de> <CAP=VYLpKjFHx7b3oTjz7a8wvxQmPME-sK147n8CX6y8+Pii2rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:61383 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758970Ab2EDQEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 12:04:48 -0400
In-Reply-To: <CAP=VYLpKjFHx7b3oTjz7a8wvxQmPME-sK147n8CX6y8+Pii2rg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 04.05.2012 16:48, schrieb Paul Gortmaker:
> On Fri, May 4, 2012 at 10:15 AM, Karsten Keil <kkeil@linux-pingi.de> wrote:
>> From: Karsten Keil <isdn@linux-pingi.de>
>>
>> With multiple cards is hard to figure out which port caused trouble
>> int the layer2 routines (e.g. got a timeout).
>> Now we have the informations in the log output.
> 
> If you are in here changing all these printk(KERN_LEVEL ...) lines anyway,
> then perhaps it is a good time to make use of pr_warn() and friends to
> help avoid some multi-line fragmentation things like this:
> 
>>                                printk(KERN_WARNING
>>                                       "%s: windowar[%d] is NULL\n",
>> -                                      __func__, p1);
>> +                                      mISDNDevName4ch(&l2->ch), p1);
>>                        l2->windowar[p1] = NULL;
> 

Good point, but this should be consolidated over the complete project.
Will put this on TODO, after the current issues are solved.

Thanks
Karsten
