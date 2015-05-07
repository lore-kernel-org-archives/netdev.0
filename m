From: Ruslan Bilovol <ruslan.bilovol-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: usb: allow MTU that is a multiple of USB packet size
Date: Thu, 7 May 2015 13:51:40 +0300
Message-ID: <CAB=otbTxAit3d8ns5PaOK_QF8oEzMbSjTuY3e+cqwrmZs8WVSA@mail.gmail.com>
References: <1430992159-27783-1-git-send-email-ruslan.bilovol@gmail.com>
	<1430993477.30151.6.camel@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1430993477.30151.6.camel-l3A5Bk7waGM@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Oliver,

On Thu, May 7, 2015 at 1:11 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
> On Thu, 2015-05-07 at 12:49 +0300, Ruslan Bilovol wrote:
>> Current usbnet driver rejects setting MTU that is a multiple
>> of USB endpoint's wMaxPacketSize size. However, it may only
>> lead to possible performance degradation but is not so
>> critical that its using should be prohibited. So allow it
>> but also warn user about possible issue.
>
> We have reports about devices reacting badly to ZLPs.
> Unless you have a compelling reasons for this change
> I have to reject it.

What devices do you mean here: USB network adapters or USB host controllers?
If it's just network adapters, then we can create some kind of quirk handling
for them and do not disable this functionality just because some buggy device
can't work with it.
My device works fine with ZLPs so I want to use this particular MTU under Linux
like I do it under other operation systems.

Regards,
Ruslan


>
>         Regards
>                 Oliver
>
> NACK
>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
