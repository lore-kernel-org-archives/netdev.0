From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH V3] rtlwifi: rtl8192cu: Add new USB ID
Date: Wed, 15 May 2013 15:34:14 -0500
Message-ID: <5193F146.3030206@lwfinger.net>
References: <1368630196-14704-1-git-send-email-Larry.Finger@lwfinger.net> <5193EEA8.8030900@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	Albert Pool <albertpool@solcon.nl>, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:34442 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755108Ab3EOUeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 16:34:20 -0400
In-Reply-To: <5193EEA8.8030900@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2013 03:23 PM, Sergei Shtylyov wrote:
> Hello.
>
> On 05/15/2013 07:03 PM, Larry Finger wrote:
>
>> From: Albert Pool <albertpool@solcon.nl>
>>
>> This adds the USB ID of the On Networks N300MA, clone of Netgear WNA3100M.
>>
>> Signed-off-by: Albert Pool <albertpool@solcon.nl>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>> Reported-by: Ana Rey <Anazul77@hotmail.com>
>> ---
>>
>> John,
>>
>> Please use this version. V2 still had some whitespace errors that I fixed.
>>
>> Albert,
>>
>> Please use scripts/checkpatch.pl to check the patch before you send it.
>>
>> Thanks,
>>
>> Larry
>> ---
>>
>>   drivers/net/wireless/rtlwifi/rtl8192cu/sw.c | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
>> b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
>> index 23d640a..18da6de 100644
>> --- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
>> +++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
>> @@ -349,6 +349,7 @@ static struct usb_device_id rtl8192c_usb_ids[] = {
>>       {RTL_USB_DEVICE(0x07aa, 0x0056, rtl92cu_hal_cfg)}, /*ATKK-Gemtek*/
>>       {RTL_USB_DEVICE(0x07b8, 0x8178, rtl92cu_hal_cfg)}, /*Funai -Abocom*/
>>       {RTL_USB_DEVICE(0x0846, 0x9021, rtl92cu_hal_cfg)}, /*Netgear-Sercomm*/
>> +    {RTL_USB_DEVICE(0x0846, 0xf001, rtl92cu_hal_cfg)}, /*On Netwrks N300MA*/
>
>     "Networks", perhaps? Or does it hit 80 columns limit this way?

That is exactly the problem. I suppose I could allow one line to be 81 
characters in length, but that would diminish the effectiveness of my suggestion 
that checkpatch be used.

Thanks for noticing. At least someone is reading the patches.

Larry
