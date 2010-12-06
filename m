From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCHv3 2/2] USB CDC NCM host driver
Date: Mon, 06 Dec 2010 12:59:29 -0800 (PST)
Message-ID: <20101206.125929.59665339.davem@davemloft.net>
References: <1291109008-3613-1-git-send-email-alexey.orishko@stericsson.com>
	<1291109008-3613-2-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh-l3A5Bk7waGM@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, yauheni.kaliuta-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org,
	sjur.brandeland-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org, alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org
To: alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1291109008-3613-2-git-send-email-alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Tue, 30 Nov 2010 12:23:28 +0300

> The patch provides USB CDC NCM host driver support in the Linux Kernel.
> 
> Changes:
> drivers/net/usb/cdc_ncm.c:
> - initial submission of the CDC NCM host driver;
> - verified on Intel 32/64 bit, Intel Atom, ST-Ericsson U8500 (ARM)
> - throughput measured over 100 Mbits duplex;
> - driver supports 16-bit NTB format only, but it is more than enough for
>   transfers up to 64K;
> - driver can handle up to 32 datagrams in received NTB;
> - timer is used to collect several packets in Tx direction
> 
> drivers/net/usb/Kconfig:
> - a new entry to compile CDC NCM host driver
> drivers/net/usb/Makefile:
> - a new entry to compile CDC NCM host driver
> 
> Signed-off-by: Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
