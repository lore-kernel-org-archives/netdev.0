From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net 2/2] r8152: rx descriptor check
Date: Sun, 13 Nov 2016 12:39:54 -0500 (EST)
Message-ID: <20161113.123954.2134945576362221851.davem@davemloft.net>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
        <1394712342-15778-228-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org
To: hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-228-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Date: Fri, 11 Nov 2016 15:15:41 +0800

> For some platforms, the data in memory is not the same with the one
> from the device. That is, the data of memory is unbelievable. The
> check is used to find out this situation.
> 
> Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>

I'm all for adding consistency checks, but I disagree with proceeding
in this manner for this.

If you add this patch now, there is a much smaller likelyhood that you
will work with a high priority to figure out _why_ this is happening.

For all we know this could be a platform bug in the DMA API for the
systems in question.

It could also be a bug elsewhere in the driver, either in setting up
the descriptor DMA mappings or how the chip is programmed.

Either way the true cause must be found before we start throwing
changes like this into the driver.

I'm not applying this series, sorry.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
