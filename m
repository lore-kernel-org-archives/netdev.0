From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: Re: [PATCH] hso: add Vendor/Product ID's for new devices
Date: Wed, 01 Apr 2009 11:43:58 +0300
Message-ID: <49D3294E.10501@teltonika.lt>
References: <20090331115652.GA22106@raptor> <49D318E7.4050404@teltonika.lt> <49D31B43.20506@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <49D31B43.20506-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jan Dumon wrote:
> Paulius Zaleckas wrote:
>> Jan Dumon wrote:
>>> From: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
>>>
>>> Add Vendor/Product ID's for new devices.
>>>
>>> Signed-off-by: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
>>> ---
>>> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
>>> index fe98aca..d47c508 100644
>>> --- a/drivers/net/usb/hso.c
>>> +++ b/drivers/net/usb/hso.c
>>> @@ -462,9 +462,16 @@ static const struct usb_device_id hso_ids[] = {
>>>  	{USB_DEVICE(0x0af0, 0x7701)},
>>>  	{USB_DEVICE(0x0af0, 0x7801)},
>>>  	{USB_DEVICE(0x0af0, 0x7901)},
>>> -	{USB_DEVICE(0x0af0, 0x7361)},
>>> -	{USB_DEVICE(0x0af0, 0xd057)},
>> Please add comment in description why you are removing these IDs.
> 
> No ID's are removed.
> 0xd057 is added again by the same patch, 0x7361 was twice in the list.

OK for 0xd057, but please add comment that you are removing duplicate
definition of 0x7361.

> 
>>> +	{USB_DEVICE(0x0af0, 0x8200)},
>>> +	{USB_DEVICE(0x0af0, 0x8201)},
>>> +	{USB_DEVICE(0x0af0, 0xd035)},
>>>  	{USB_DEVICE(0x0af0, 0xd055)},
>>> +	{USB_DEVICE(0x0af0, 0xd155)},
>>> +	{USB_DEVICE(0x0af0, 0xd255)},
>>> +	{USB_DEVICE(0x0af0, 0xd057)},
>>> +	{USB_DEVICE(0x0af0, 0xd157)},
>>> +	{USB_DEVICE(0x0af0, 0xd257)},
>>> +	{USB_DEVICE(0x0af0, 0xd357)},
>>>  	{}
>>>  };
>>>  MODULE_DEVICE_TABLE(usb, hso_ids);
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
