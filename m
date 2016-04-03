From: poma <pomidorabelisima-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: GDM7240 - NULL pointer dereference
Date: Sun, 3 Apr 2016 14:26:45 +0200
Message-ID: <57010C05.1050107@gmail.com>
References: <5700ED33.6020200@zoho.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
To: Alex <alex3kov-ytc+IHgoah0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5700ED33.6020200-ytc+IHgoah0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03.04.2016 12:15, Alex wrote:
> Hello,
> [1.] System hang when connecting USB modem (LU150)
> [2.] I'm running 4.4.5 kernel (Arch Linux). When this modem is connected 
> I'm getting below trace in journal and system becomes unusable - lsusb, 
> logout and some other operations lead to a complete hang, the only way 
> out is hardware power off. This modem works perfectly on 4.1.20 kernel - 
> attaching all outputs for both kernels.
...

See if it is related to
http://thread.gmane.org/gmane.linux.usb.general/135626

if so, kernel >= 4.5
i.e.
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/drivers/net/usb/cdc_ether.c?h=linux-4.5.y&id=29c6dd5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
