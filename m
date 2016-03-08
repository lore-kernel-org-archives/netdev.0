From: Andrey Konovalov <andreyknvl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Possible double-free in the usbnet driver
Date: Tue, 8 Mar 2016 14:42:06 +0300
Message-ID: <CA+fCnZfLbYhh7iS6rpu_WaKt+vYDPKH1bkxwDchCow6Xm+Kskw@mail.gmail.com>
References: <1457193090.8935.7.camel@suse.com>
	<DBDB517D-E4A4-4422-AECE-52194FE2AED0@mork.no>
	<CA+55aFw43uKkUK-h=VMwXcb9NM+g2AdeB960kWb4YihmjQ8DRw@mail.gmail.com>
	<20160307.141100.1511700720120062677.davem@davemloft.net>
	<CA+fCnZdurxGBsOrANb_m5BLK1BKzH3J_GmZ=dbH=ABThgFNGxg@mail.gmail.com>
	<1457386754.3404.15.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Kostya Serebryany <kcc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	=?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1457386754.3404.15.camel-IBi9RG/b67k@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 8, 2016 at 12:39 AM, Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org> wrote:
> On Mon, 2016-03-07 at 22:50 +0300, Andrey Konovalov wrote:
>> Could you also add:
>> Reported-by: Andrey Konovalov <andreyknvl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>
> Well, the exact bug you reported is fixed in Bjorn's
> patch the way Linus suggested. I'm fixing just a further
> race that would require an error condition on top
> of what you have seen.
> So I don't think your Reported-by would be totally
> appropriate.

Oh, OK, Sorry. I thought this was a part of the same fix.

>
>         Regards
>                 Oliver
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
