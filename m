From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Fri, 12 Oct 2012 23:33:24 +0800
Message-ID: <CACVXFVPoh5+GAFHP0n9_CqYaCaKnUreL_-82e_=y1vzpaE4+zA@mail.gmail.com>
References: <Pine.LNX.4.44L0.1210111030570.1170-100000@iolanthe.rowland.org>
	<3535515.7NRjKhCcrL@linux-lqwf.site>
	<CACVXFVOChR3ZJSyjo44AMwzzjx5URWvEe25KY2eV5evJpF9D+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jkosina-IBi9RG/b67k@public.gmane.org
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVOChR3ZJSyjo44AMwzzjx5URWvEe25KY2eV5evJpF9D+g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 12, 2012 at 11:17 PM, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:

> Suppose mutex_lock(A) is called in pre_reset(), one solution is that
> always calling tsk_set_allowd_gfp(~GFP_IOFS) before each mutex_lock(A).
> We can do it only for devices with storage interface in current
> configuration.

The problem will become quite complicated if a 3rd, even 4th,... context
is involved in the task dependency.

But I am wondering if there are such practical examples wrt. usb
mass storage.

Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
