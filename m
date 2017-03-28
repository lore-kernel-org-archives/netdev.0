From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: Re: [PATCHv2] net: usbnet: support 64bit stats in qmi_wwan driver
Date: Tue, 28 Mar 2017 10:01:40 +0200
Message-ID: <1490688100.29898.1.camel@suse.com>
References: <1490318850-23252-1-git-send-email-gerg@linux-m68k.org>
         <1490331560.9687.42.camel@edumazet-glaptop3.roam.corp.google.com>
         <44b9bf7a-70e5-a5f7-53f0-4ea3205638f1@linux-m68k.org>
         <1490365070.9687.46.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bjorn-yOkvZcmFvRU@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Greg Ungerer <gerg-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1490365070.9687.46.camel-XN9IlZ5yJG9HTL0Zs8A6p+yfmBU6pStAUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Freitag, den 24.03.2017, 07:17 -0700 schrieb Eric Dumazet:
> On Fri, 2017-03-24 at 15:42 +1000, Greg Ungerer wrote:
> 
> > 
> > The usbnet core is used by a number of drivers. This patch only
> > updates the qmi-wwan driver to use stats64. If you remove the
> > dev->stats.rx_* updates all those other driver users will have
> > no counts.
> 
> I see. Then I guess the u64 stuff could be done only if running 32bit
> kernels. (The existing stats are using 'unsigned long' so are already
> 64bit wide on 64bit kernels)

We want every driver to use u64 if possible. If something
is exported we want a defined size.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
