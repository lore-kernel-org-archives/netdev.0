From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Thu, 11 Oct 2012 19:29:44 +0800
Message-ID: <CACVXFVNearJj+o7s=Pk=tyQBnwvapEX=pe9A+AxheiSNGZBdyQ@mail.gmail.com>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
	<1588459.VLxBbnNMlP@linux-lqwf.site>
	<CACVXFVPjx+053r_-QB=8kPCDmk3va3feN9MYdLgpf=eRWGe05A@mail.gmail.com>
	<1940520.W6hRn23j86@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1940520.W6hRn23j86-ugxBuEnWX9yG/4A2pS7c2Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 11, 2012 at 5:05 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
> That depends on whether an API change would be necessary.
> Changing the code only when necessary is no problem. But the
> API I want to do right from the beginning if that is possible.

For the auto-resume situation, the current API is OK even without
changes to task_struct.

>
> This depends on whether you get in your extension to task_struct.
> If you do, we can certainly use it also for the suspend case.

I will do it.

>
>> For error handling case, it is inevitably for usbnet to allocate memory
>> with GFP_KERNEL because no usbnet drivers have implemented
>> .pre_reset and .post_reset callback, and no such actual problems
>> have been reported until now, so it should be OK to not consider the
>> case now.
>>
>> So could we merge the patch set[1-11] first?
>
> Given the solution for error handling you came up with, yes, we can.
> Would you resubmit?

OK, will do it.

Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
