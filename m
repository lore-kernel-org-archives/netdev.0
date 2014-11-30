From: Vladimir Kondratiev <qca_vkondrat-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: Question about function. wil_vring_alloc_skb in txrx.c
Date: Sun, 30 Nov 2014 10:39:03 +0200
Message-ID: <8489393.vIdH6vj4qd@lx-wigig-72>
References: <547A5554.3010900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<wil6210-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: nick <xerofoify-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <547A5554.3010900-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday, November 29, 2014 06:23:00 PM nick wrote:
> Greetings Vladimr,John and others,
> I am wondering about the TODO in the function in my message at it seems to be no longer needed due to us reserving headroom for the skb packet used in this function. The other reason I can see that this is needed is if we need to 
> align the sk_buff for performance or hardware alignment reasons. If that is the case, would someone we willing to
> explain to me how the maintainers would like me to align the sk_buff packet used in the function, wil_vring_alloc_skb.
Hi Nick,
ignore this TODO, I'll remove it. I was not sure what is better for the hardware, now I know there is no hardware
limitation.

Thanks, Vladimir
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
