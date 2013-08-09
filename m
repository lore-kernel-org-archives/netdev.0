From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/2] net/usb: catc: allocate URB setup_packet as
 separate buffer
Date: Fri, 09 Aug 2013 13:42:22 -0700 (PDT)
Message-ID: <20130809.134222.2239756285423925844.davem@davemloft.net>
References: <20130807132629.14001.2370.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jussi.kivilinna-X3B1VOXEql0@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130807132629.14001.2370.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jussi Kivilinna <jussi.kivilinna-X3B1VOXEql0@public.gmane.org>
Date: Wed, 07 Aug 2013 16:26:29 +0300

> URB setup packet must not be allocated as part of larger structure
> because DMA coherence issues.
> 
> Patch changes catc to allocate ctrl_dr member as separate buffer.
> 
> Patch is only compile tested.
> 
> Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna-X3B1VOXEql0@public.gmane.org>

I absolutely do not agree with your adding the stable CC: tag for
a patch which has only been compile tested.

This applies to all of your other patches you submitted in this
cluster too.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
