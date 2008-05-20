From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [patch 2/3] hci_usb: remove code obfuscation
Date: Tue, 20 May 2008 19:26:42 +0200
Message-ID: <3E40C481-B07D-446B-8B22-013173C6074C@holtmann.org>
References: <200804182046.m3IKks86014628@imap1.linux-foundation.org> <9BEB490E-DE8A-4018-9696-E5074CC638AC@holtmann.org> <20080418223430.GA13847@elf.ucw.cz> <6A7ADC8A-E229-4EC6-9C75-00359946037F@holtmann.org> <20080419161456.GB1577@elf.ucw.cz> <15B7927A-D74F-450D-A6A4-0204FAD455F6@holtmann.org> <20080520152405.GC2067@elf.ucw.cz>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080520152405.GC2067-I/5MKhXcvmPrBKCeMvbIDA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Pavel,

>>> There needs to be some load on the usb. I use
>>> rsync-over-bt-over-gprs/umts.
>>
>> you told me before and I believe you. This driver is not in its  
>> best shape.
>> Weird thing is that I never got it re-produced. If you find the  
>> real cause.
>> That would be great.
>
> The cause seems to be hci_usb_close() racing with the USB core and
> completion handlers...
>
>>>>> It could be easily fixed by just not freeing the urbs during
>>>>> disconnect (introducing very very slow memory leak). Would that be
>>>>> acceptable?
>>>>
>>>> I don't think so.
>>>>
>>>> Have you ever tried btusb driver? That code is a lot cleaner and  
>>>> it uses
>>>> USB anchors for the queued URBs (no home grown broken URB queues).
>>>
>>> I wish I knew about  this one earlier. Yes, it seems to work for me.
>>
>> Does this mean you are not fixing hci_usb anymore ;)
>
> I'm not sure what's next, as hci_usb is still in opensuse11...

the goal should be improve btusb. Especially add all the needed quirks  
from the hci_usb driver to it. I have a patch for it, but I need to  
reverse the HCI_RESET logic.

However if you have hci_usb patches, send them, I will review them and  
David will happily apply them I guess.

Regards

Marcel
