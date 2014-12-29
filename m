From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [RFC PATCH 2/6] cdc_ncm: be more precise in comments for
 cdc_ncm_prepare_skb_ncm16
Date: Mon, 29 Dec 2014 14:37:18 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1412291436080.3067@gmail.com>
References: <1419847788-25610-1-git-send-email-mrkiko.rs@gmail.com> <1419847788-25610-3-git-send-email-mrkiko.rs@gmail.com> <54A15744.2050602@cogentembedded.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:35930 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440AbaL2Nh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 08:37:29 -0500
Received: by mail-wi0-f176.google.com with SMTP id ex7so22085260wid.9
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 05:37:28 -0800 (PST)
In-Reply-To: <54A15744.2050602@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you Sergei: for your time and review. I'll be careful to this.
Wish you best regards too - and good new year!

Enrico



On Mon, 29 Dec 2014, Sergei Shtylyov wrote:

> Date: Mon, 29 Dec 2014 14:29:40
> From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> To: Enrico Mioso <mrkiko.rs@gmail.com>, netdev@vger.kernel.org
> Subject: Re: [RFC PATCH 2/6] cdc_ncm: be more precise in comments for
>     cdc_ncm_prepare_skb_ncm16
> 
> Hello.
>
> On 12/29/2014 1:09 PM, Enrico Mioso wrote:
>
>> The function might return NULL: callers must be prepared to this 
>> possibility.
>
>> Signed-Off-By: Enrico Mioso <mrkiko.rs@gmail.com>
>> ---
>>   drivers/net/usb/cdc_ncm.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>
>> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
>> index 48fee7a..bcd9437 100644
>> --- a/drivers/net/usb/cdc_ncm.c
>> +++ b/drivers/net/usb/cdc_ncm.c
>> @@ -1015,7 +1015,7 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp16(struct 
>> cdc_ncm_ctx *ctx, struct s
>>   }
>>
>>   /* Allocate new SKB for use with 16-bit NCM according to actual TX/RX
>> -	settings */
>> +	settings; returns NULL in case of errors */
>
>   BTW, the preferred style for the multi-line comments in the networking 
> code is:
>
> /* bla
> * bla
> */
>
> WBR, Sergei
>
>
