From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 00/11] usbnet: usb_control_msg cleanup
Date: Fri, 26 Oct 2012 03:37:11 -0400 (EDT)
Message-ID: <20121026.033711.358966728996356537.davem@davemloft.net>
References: <1351144024-16596-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, oneukum-l3A5Bk7waGM@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1351144024-16596-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date: Thu, 25 Oct 2012 13:46:53 +0800

> This patch set introduces 3 helpers for handling usb read, write
> and write_async command, and replaces the low level's implemention
> with the generic ones.
> 
> This patchset is a cleanup and about 300 lines code is saved.
> 
> Also, the patchset fixes problem of DMA on buffer embedded inside
> one dynamic allocated buffer, and such usages can be found
> in cdc-ncm, sierra_net, mcs7830 and asix drivers.

All applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
