From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] net: rfkill: gpio: Add OBDA8723 ACPI HID
Date: Sun, 9 Apr 2017 10:50:30 -0500
Message-ID: <d63b1718-910a-09e2-7a2a-f34c08c11ce6@lwfinger.net>
References: <20170408210520.2799-1-hdegoede@redhat.com>
 <D47F8D1B-8EE0-4754-A0F2-EC823A9BDA11@holtmann.org>
 <d1206383-7fad-55ca-0717-5e485b9bee92@redhat.com>
 <0939E68A-DBF5-40BF-B83B-73AF234EB60B@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        russianneuromancer-k+OT61UuxXo@public.gmane.org,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <0939E68A-DBF5-40BF-B83B-73AF234EB60B-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/09/2017 07:11 AM, Marcel Holtmann wrote:
> Hi Hans,
>
>>>> The OBDA8723 ACPI HID is used on quite a few Bay Trail based tablets
>>>> for bluetooth rfkill functionality.
>>>>
>>>> Tested-by: russianneuromancer-k+OT61UuxXo@public.gmane.org <russianneuromancer-k+OT61UuxXo@public.gmane.org>
>>>> Signed-off-by: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>>> ---
>>>> net/rfkill/rfkill-gpio.c | 1 +
>>>> 1 file changed, 1 insertion(+)
>>>>
>>>> diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
>>>> index 76c01cb..50ca65e 100644
>>>> --- a/net/rfkill/rfkill-gpio.c
>>>> +++ b/net/rfkill/rfkill-gpio.c
>>>> @@ -163,6 +163,7 @@ static int rfkill_gpio_remove(struct platform_device *pdev)
>>>> static const struct acpi_device_id rfkill_acpi_match[] = {
>>>> 	{ "BCM4752", RFKILL_TYPE_GPS },
>>>> 	{ "LNV4752", RFKILL_TYPE_GPS },
>>>> +	{ "OBDA8723", RFKILL_TYPE_BLUETOOTH },
>>>> 	{ },
>>>> };
>>>
>>> NAK. We are integrating these with hci_bcm.c or hci_intel.c drivers.
>>
>> This is for the bluetooth side of the rtl8723bs driver which recently
>> (yesterday) got merged in into drivers/staging. Which still needs
>> hciattach from userspace. I completely agree that eventually we should
>> fix that. In the mean time it would be nice if we could carry this
>> one line patch to give people using the staging driver working bluetooth.
>
> why are Bluetooth drivers in staging? I objected to them before. The only reason to have them in staging would be people being to lazy to clean things up.

The Bluetooth driver is not in staging. It is only the wifi part; however, 
having a driver for that hardware in the kernel makes it easier for users to 
handle the BT part of the device. As Hans stated, the current BT driver runs in 
userspace. Until we actually produce hci_rtk, having this one line patch will be 
helpful.

Larry



-- 
If I was stranded on an island and the only way to get off
the island was to make a pretty UI, I’d die there.

Linus Torvalds
