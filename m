From: Albert Pool <albertpool-2BgBnwcziRhmR6Xm/wNWPw@public.gmane.org>
Subject: Re: [PATCH V3] rtlwifi: rtl8192cu: Add new USB ID
Date: Thu, 16 May 2013 11:04:44 +0200
Message-ID: <5194A12C.6010807@solcon.nl>
References: <1368630196-14704-1-git-send-email-Larry.Finger@lwfinger.net> <5193EEA8.8030900@cogentembedded.com> <5193F146.3030206@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5193F146.3030206-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Op 15-05-13 22:34, Larry Finger schreef:
> On 05/15/2013 03:23 PM, Sergei Shtylyov wrote:
>> Hello.
>>
>> On 05/15/2013 07:03 PM, Larry Finger wrote:
>>
>>> From: Albert Pool <albertpool-2BgBnwcziRhmR6Xm/wNWPw@public.gmane.org>
>>>
>>> This adds the USB ID of the On Networks N300MA, clone of Netgear 
>>> WNA3100M.
>>>
>>> Signed-off-by: Albert Pool <albertpool-2BgBnwcziRhmR6Xm/wNWPw@public.gmane.org>
>>> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
>>> Reported-by: Ana Rey <Anazul77-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
>>> ---
>>>
>>> John,
>>>
>>> Please use this version. V2 still had some whitespace errors that I 
>>> fixed.
>>>
>>> Albert,
>>>
>>> Please use scripts/checkpatch.pl to check the patch before you send it.
>>>
>>> Thanks,
>>>
>>> Larry
>>> ---
>>>
>>>   drivers/net/wireless/rtlwifi/rtl8192cu/sw.c | 1 +
>>>   1 file changed, 1 insertion(+)
>>>
>>> diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
>>> b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
>>> index 23d640a..18da6de 100644
>>> --- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
>>> +++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
>>> @@ -349,6 +349,7 @@ static struct usb_device_id rtl8192c_usb_ids[] = {
>>>       {RTL_USB_DEVICE(0x07aa, 0x0056, rtl92cu_hal_cfg)}, 
>>> /*ATKK-Gemtek*/
>>>       {RTL_USB_DEVICE(0x07b8, 0x8178, rtl92cu_hal_cfg)}, /*Funai 
>>> -Abocom*/
>>>       {RTL_USB_DEVICE(0x0846, 0x9021, rtl92cu_hal_cfg)}, 
>>> /*Netgear-Sercomm*/
>>> +    {RTL_USB_DEVICE(0x0846, 0xf001, rtl92cu_hal_cfg)}, /*On Netwrks 
>>> N300MA*/
>>
>>     "Networks", perhaps? Or does it hit 80 columns limit this way?
>
> That is exactly the problem. I suppose I could allow one line to be 81 
> characters in length, but that would diminish the effectiveness of my 
> suggestion that checkpatch be used.
>
> Thanks for noticing. At least someone is reading the patches.
>
> Larry
>
>
So my patch v2 could not be used because the line was longer than 80 
chars? (It was 82, indeed)

Also the problems with bad signal were due to Ana Rey's AP. It's being 
fixed or replaced today.

Albert
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
