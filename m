From: "Artem S. Tashkinov" <t.artem-DVq+YeWbj7cAvxtiuMwx3w@public.gmane.org>
Subject: Re: Re: A reliable kernel panic (3.6.2) and system crash when
 visiting a particular website
Date: Sun, 21 Oct 2012 12:30:15 +0000 (GMT)
Message-ID: <317435358.100327.1350822615555.JavaMail.mail@webmail20>
References: <2104474742.26357.1350734815286.JavaMail.mail@webmail05>
 <20121020162759.GA12551@liondog.tnic>
 <966148591.30347.1350754909449.JavaMail.mail@webmail08>
 <20121020203227.GC555@elf.ucw.cz> <20121020225849.GA8976@liondog.tnic>
 <1781795634.31179.1350774917965.JavaMail.mail@webmail04>
 <20121021002424.GA16247@liondog.tnic>
 <1798605268.19162.1350784641831.JavaMail.mail@webmail17>
 <20121021110851.GA6504@liondog.tnic>
 <121566322.100103.1350820776893.JavaMail.mail@webmail20>
 <5083E4AA.3060807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org, pavel-+ZI9xUNit7I@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, security-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: zonque-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Oct 21, 2012, Daniel Mack wrote: 

> A hint at least. How did you enable the audio record exactly? Can you
> reproduce this with arecord?
> 
> What chipset are you on? Please provide both "lspci -v" and "lsusb -v"
> dumps. As I said, I fail to reproduce that issue on any of my machines.

All other applications can read from the USB audio without problems, it's
just something in the way Adobe Flash polls my audio input which causes
a crash.

Just video capture (without audio) works just fine in Adobe Flash.

Only and only when I choose to use 

USB Device 0x46d:0x81d my system crashes in Adobe Flash.

See the screenshot:

https://bugzilla.kernel.org/attachment.cgi?id=84151

My hardware information can be fetched from here:

https://bugzilla.kernel.org/show_bug.cgi?id=49181

On a second thought that can be even an ALSA crash or pretty much
anything else.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
