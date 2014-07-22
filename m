From: Nick Krause <xerofoify@gmail.com>
Subject: Re: [PATCH] atm: Remove fix me in solos-pci
Date: Tue, 22 Jul 2014 13:47:37 -0400
Message-ID: <CAPDOMVge=KHmModReK8PuK123kbJp8MmGpKhkjPdrAeP5gvg0g@mail.gmail.com>
References: <1406002040-7334-1-git-send-email-xerofoify@gmail.com>
	<20140722074332.52b8c66b@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f171.google.com ([209.85.220.171]:60655 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756129AbaGVRri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 13:47:38 -0400
Received: by mail-vc0-f171.google.com with SMTP id hq11so14157043vcb.30
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 10:47:37 -0700 (PDT)
In-Reply-To: <20140722074332.52b8c66b@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 22, 2014 at 7:43 AM, chas williams - CONTRACTOR
<chas@cmf.nrl.navy.mil> wrote:
> Guy Ellis of Transverse says that Nathan Williams,
> nathan@traverse.com.au, will address this issue when he returns
> from vacation.  So let's just wait for the 'official' fix.
>
> On Tue, 22 Jul 2014 00:07:20 -0400
> Nicholas Krause <xerofoify@gmail.com> wrote:
>
>> This removes a fix me as the default statement for solos_bh is correct
>> and needs no fixing.
>>
>> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
>> ---
>>  drivers/atm/solos-pci.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
>> index 943cf0d..58a0a8f 100644
>> --- a/drivers/atm/solos-pci.c
>> +++ b/drivers/atm/solos-pci.c
>> @@ -851,7 +851,7 @@ static void solos_bh(unsigned long card_arg)
>>                               break;
>>
>>                       case PKT_COMMAND:
>> -                     default: /* FIXME: Not really, surely? */
>> +                     default:
>>                               if (process_command(card, port, skb))
>>                                       break;
>>                               spin_lock(&card->cli_queue_lock);
>
Very well then I just this is closed.
Cheers Nick
