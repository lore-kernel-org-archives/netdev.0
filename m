From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Mon, 21 Apr 2008 16:00:18 +0300
Message-ID: <480C8FE2.4020204@teltonika.lt>
References: <20080414213238.GB28833@kroah.com> <200804211345.12850.oliver@neukum.org> <480C8AD8.9050609@teltonika.lt> <200804211450.27093.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200804211450.27093.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Oliver Neukum wrote:
> Am Montag, 21. April 2008 14:38:48 schrieb Paulius Zaleckas:
>> Oliver Neukum wrote:
>>> Am Freitag, 18. April 2008 17:18:29 schrieb Paulius Zaleckas:
>>>> Oliver Neukum wrote:
>>>>> Hi,
>>>>>
>>>>> can you test this one as well. The method used to determine whether
>>>>> a device is asleep is racy. This introduces a private test.
>>>>>
>>>>> 	Regards
>>>>> 		Oliver
>>>> By setting level "auto" it didn't suspend...
>>>> When I tried to set "suspend" to the level I got crash:
>>> Does this fix it?
>> Looks like it fixed this crash.
>> I don't see anything on dmesg and /var/log/messages when I do
>> echo "suspend" > power/level, but that is IMO another story.
> 
> Did you compile with CONFIG_USB_DEBUG? Do you load usbcore
> from initrd? In that case you need to rebuild your initrd.

Actually I am using 2.6.24.4-64.fc8debug kernel.
I failed to start my 2.6.25 compiled kernel, because of some mkinitrd
incompatibilities with LVM (I hate that day when I installed Fedora on
LVM partition :))
According to fedora config CONFIG_USB_DEBUG is enabled. Couldn't find
usbcore on initrd image...

Paulius

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
