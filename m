From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH net 2/2] r8152: rx descriptor check
Date: Mon, 14 Nov 2016 07:03:51 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB20104EB65@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
        <1394712342-15778-228-Taiwan-albertk@realtek.com>
 <20161113.123954.2134945576362221851.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        nic_swsd <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org" <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161113.123954.2134945576362221851.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Language: zh-TW
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller [mailto:davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org]
> Sent: Monday, November 14, 2016 1:40 AM
[...]
> If you add this patch now, there is a much smaller likelyhood that you
> will work with a high priority to figure out _why_ this is happening.
> 
> For all we know this could be a platform bug in the DMA API for the
> systems in question.
> 
> It could also be a bug elsewhere in the driver, either in setting up
> the descriptor DMA mappings or how the chip is programmed.
> 
> Either way the true cause must be found before we start throwing
> changes like this into the driver.

Our hw engineer could check our device, and I could check the
driver. However, for the other parts, such as the USB host
controller or memory, it is difficult for me to make sure whether
they are correct or not. I could only promise our devices and
driver work fine.

Best Regards,
Hayes

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
