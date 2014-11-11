From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2] usbnet: smsc95xx: dereferencing NULL pointer
Date: Tue, 11 Nov 2014 16:25:00 -0500 (EST)
Message-ID: <20141111.162500.469910623806405034.davem@davemloft.net>
References: <1415695247-30442-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1415695247-30442-1-git-send-email-sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Tue, 11 Nov 2014 14:10:47 +0530

> we were dereferencing dev to initialize pdata. but just after that we
> have a BUG_ON(!dev). so we were basically dereferencing the pointer
> first and then tesing it for NULL.
> 
> Signed-off-by: Sudip Mukherjee <sudip-ofJRbWXBVFamYgehrs7/Lw@public.gmane.org>
> ---
> 
> change in v2: suspend_flags is initialised after pdata is initialised.
> v1 had a very silly but serious mistake of making pdata NULL, and trying
> to dereference it.
> sorry again for that.

This looks better, applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
