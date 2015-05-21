From: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [RESEND][PATCH] Bluetooth: Make request workqueue freezable
Date: Thu, 21 May 2015 19:27:41 +0200
Message-ID: <555E158D.4090607@broadcom.com>
References: <33C25745-6839-4858-9A3E-19EC6408ECED@holtmann.org>	<Pine.LNX.4.44L0.1505211112310.1397-100000@iolanthe.rowland.org> <s5hsiaq3pv4.wl-tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Laura Abbott <labbott-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>,
	Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Laura Abbott <labbott-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>,
	"Johan Hedberg" <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Rafael J. Wysocki" <rafael.j.wysocki-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	"bluez mailin list (linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org)"
	<linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <s5hsiaq3pv4.wl-tiwai-l3A5Bk7waGM@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/21/15 17:35, Takashi Iwai wrote:
> At Thu, 21 May 2015 11:26:17 -0400 (EDT),
> Alan Stern wrote:
>>
>> On Thu, 21 May 2015, Takashi Iwai wrote:
>>
>>> At Thu, 21 May 2015 10:18:08 -0400 (EDT),
>>> Alan Stern wrote:
>>>>
>>>> On Thu, 21 May 2015, Takashi Iwai wrote:
>>>>
>>>>> Then avoiding the failed firmware is no solution, indeed.
>>>>> If it's a new probe, it should be never executed during resume.
>>>>
>>>> Can you expand this comment?  What's wrong with probing during resume?
>>>
>>> Well, if the probe requires the access to a user-space file, it can't
>>> be done during resume.  That's the very problem we're seeing now.
>>> The firmware loader can't help much alone if it's a new device
>>> object.
>>
>> But the same thing happens during early boot, if the driver is built
>> into the kernel.  When the probe occurs, userspace isn't up and running
>> yet, so the firmware loader can't do anything.
>>
>> Why should probe during resume be any worse than probe during early
>> boot?
>
> The early boot has initrd, so the files can be there.  But the resume
> has no way to fetch the file except for cached data.

but initrd is optional so without initrd it is pretty much the same.

Regards,
Arend

> Takashi
> --
> To unsubscribe from this list: send the line "unsubscribe linux-bluetooth" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
