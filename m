From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Wed, 30 Nov 2016 11:58:58 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB201057793@RTITMBSV03.realtek.com.tw>
References: <ed0c9790-57be-8bca-cdd6-3a54ca24f0bd@pobox.com>
        <20161125095350.GA20653@kroah.com>
        <1816ec7e-2733-f4ba-5d30-29dbabd20aad@pobox.com>
 <20161125.115827.2014848246966159357.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org" <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
        "romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org" <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        nic_swsd <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org" <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161125.115827.2014848246966159357.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Language: zh-TW
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Mark Lord <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
[...]
> > Not sure why, because there really is no other way for the data to
> > appear where it does at the beginning of that URB buffer.
> >
> > This does seem a rather unexpected burden to place upon someone
> > reporting a regression in a USB network driver that corrupts user data.
> 
> If you are the only person who can actively reproduce this, which
> seems to be the case right now, this is unfortunately the only way to
> reach a proper analysis and fix.

I have tested it with iperf more than five days without any error.
I would think if there is any other way to reproduce it.

Best Regards,
Hayes

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
