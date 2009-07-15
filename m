From: Christian Tramnitz <chris.ace-hi6Y0CQ0nG0@public.gmane.org>
Subject: Re: Belkin F5D5055 not really working with the asix driver
Date: Wed, 15 Jul 2009 11:17:36 +0200
Message-ID: <4A5D9EB0.3000909@gmx.net>
References: <1295ed070811040131p9170c37r5435750fa17a6f43@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1295ed070811040131p9170c37r5435750fa17a6f43-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sorry for hijacking this really old report (and for cross-posting to USB 
where I think it may belong too).
I'm having the same problem with a Belkin f5d5055 but could gather some 
more details:

The adapter only refuses to work after a cold reboot (poweroff / 
powerup) while it is actually working when hotplugged into a running 
system (including consecutive reboots).

Does anyone have an idea what could be causing this?
The same system (and components like cable, switches) were running fine 
with an AX88772 based adapter, but the AX88178 seems to behave 
differently...


Thanks,
    Christian


Pantelis Koukousoulas wrote:
> Hi, I got a belkin f5d5055 usb 2.0 gigabit adapter that should be
> supported by usbnet + the asix driver, still although recognized it
> doesn't actually work. More specifically, the card is recognized, the
> interface is created and brought up etc only no packets flow from/to
> the device.
> 
> I tried the exact same card, cable and router combination with windows
> and it works fine (ping, dhcp everything) so I suspect the driver
> might be the problem.
> 
> I recompiled with debug information enabled and I attach the trace,
> hoping it will help.
> I can also provide usbmon traces and a usbsnoop trace from the windows
> machine where it works if needed.
> 
> Unfortunately I don't have the time to dig through the datasheets/code
> to fix the problem myself :(
> 
> Thanks in advance.
> 
> P.s., Please CC me in any replies since I 'm not subscribed in this list

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
