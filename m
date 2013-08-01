From: Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] USBNET: ax88179_178a: enable tso if host supports sg dma
Date: Thu, 1 Aug 2013 09:12:23 -0700
Message-ID: <CANEJEGuLoC0NWzwP1ZTAw0nwY7uWumJpTy5LQGdaQihVzPmg0w@mail.gmail.com>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
	<1375267909-30373-5-git-send-email-ming.lei@canonical.com>
	<CANEJEGuY3WzxnN4NEKx0RxAJNPO_hy+yt2AqhuTqHQavmawTcw@mail.gmail.com>
	<1375371400.10515.155.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1375371400.10515.155.camel@edumazet-glaptop>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 1, 2013 at 8:36 AM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
...
>> IIRC, cpu_to_leXX() macros return the endian "corrected" value.
>> In other words, they need to be assigned to something, no?
>
> Nope, this in in-place byte swapping (for Big Endian only)

Ah ok - thanks for clarifying. I couldn't find the implementation and
this documentation also helped:
   http://kernelnewbies.org/EndianIssues

I don't remember implementing in-place endian correction for
arch/parisc (which is BE). I was expecting to find a generic
definition that did a load/swap/store and didn't.

thanks,
grant
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
