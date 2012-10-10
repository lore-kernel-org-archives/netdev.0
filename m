From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 12/12] usbnet: make device out of suspend before calling usbnet_read/write_cmd
Date: Wed, 10 Oct 2012 14:00:38 +0800
Message-ID: <CACVXFVNFKq04bZG1fghy6mtiFmPDkVRrh7zw093xnWfayoXvYQ@mail.gmail.com>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
	<1349160684-6627-13-git-send-email-ming.lei@canonical.com>
	<2913414.gCAxlQ38lG@linux-lqwf.site>
	<CACVXFVNb-APsJG=ejW+2jqxTfAFsGhHovpgpsyvk6wUoKn5TzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVNb-APsJG=ejW+2jqxTfAFsGhHovpgpsyvk6wUoKn5TzA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 10, 2012 at 10:33 AM, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> Good catch, thanks for your review.
>
> As far as I can think of, the mutex_is_locked() trick can solve the problem.
>
> How about the attached patch?

This one is still not good.

After further thought, it may be better to fix the problem in net
core(dev_ioctl)
because the problem happens on other net devices too.

Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
