From: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] hso: add Vendor/Product ID's for new devices
Date: Wed, 01 Apr 2009 17:00:03 +0200
Message-ID: <49D38173.6050103@option.com>
References: <Pine.LNX.4.44L0.0904010954190.3360-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.44L0.0904010954190.3360-100000-IYeN2dnnYyZXsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Alan Stern wrote:
> On Wed, 1 Apr 2009, Jan Dumon wrote:
> 
>> From: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
>>
>> Add Vendor/Product ID's for new devices.
>> Removed duplicate product ID 0x7361.
>>
>> Signed-off-by: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
>> ---
>> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
>> index fe98aca..d47c508 100644
>> --- a/drivers/net/usb/hso.c
>> +++ b/drivers/net/usb/hso.c
>> @@ -462,9 +462,16 @@ static const struct usb_device_id hso_ids[] = {
>>  	{USB_DEVICE(0x0af0, 0x7701)},
>>  	{USB_DEVICE(0x0af0, 0x7801)},
>>  	{USB_DEVICE(0x0af0, 0x7901)},
>> -	{USB_DEVICE(0x0af0, 0x7361)},
>> -	{USB_DEVICE(0x0af0, 0xd057)},
>> +	{USB_DEVICE(0x0af0, 0x8200)},
>> +	{USB_DEVICE(0x0af0, 0x8201)},
>> +	{USB_DEVICE(0x0af0, 0xd035)},
>>  	{USB_DEVICE(0x0af0, 0xd055)},
>> +	{USB_DEVICE(0x0af0, 0xd155)},
>> +	{USB_DEVICE(0x0af0, 0xd255)},
>> +	{USB_DEVICE(0x0af0, 0xd057)},
>> +	{USB_DEVICE(0x0af0, 0xd157)},
>> +	{USB_DEVICE(0x0af0, 0xd257)},
>> +	{USB_DEVICE(0x0af0, 0xd357)},
>>  	{}
>>  };
>>  MODULE_DEVICE_TABLE(usb, hso_ids);
> 
> Is this list supposed to be kept in numerical order?  The entries for
> 0xd057 and 0xd157 are in the wrong place.

We have an internal document with all the product ID's we use and I've followed that order. That way
it's a lot easier for me to compare the two and spot the missing ID's every time the list gets updated.

The devices with ID's 0x[0-2]55 are all from the same 'family' as are those with ID's 0x[0-3]57.
That is why they are out of numerical order...

Greets,
Jan.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
