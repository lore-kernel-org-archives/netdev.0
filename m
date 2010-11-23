From: Viral Mehta <Viral.Mehta-oonXi/34qI7c+919tysfdA@public.gmane.org>
Subject: RE: [PATCH 1/2] usbnet: changes for upcoming cdc_ncm driver
Date: Tue, 23 Nov 2010 23:09:34 +0530
Message-ID: <D69C90565D53114396BF743585AF5A09122E61E8A3@VSHINMSMBX01.vshodc.lntinfotech.com>
References: <1290531088-2393-1-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org" <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	"yauheni.kaliuta-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org" <yauheni.kaliuta-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	"felipe.balbi-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org" <felipe.balbi-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	"sjur.brandeland-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org" <sjur.brandeland-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"gregkh-l3A5Bk7waGM@public.gmane.org" <gregkh-l3A5Bk7waGM@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1290531088-2393-1-git-send-email-alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

>Signed-off-by: Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
>---
>Changes:
>drivers/net/usb/usbnet.c:
>- the procedure of counting packets in usbnet was updated due to the
 >accumulating of IP packets in the CDC NCM driver
>- no short packets sent for cdc_ncm driver
>include/linux/usb/usbnet.h:
>- a new flag to indicate driver's capability to accumulate IP packets in one
 >skb before sending them (Tx direction)

Feels like good to have these comments in comment log itself (i..e, above Signed-off-by line)
Same for another patch as well.

Viral

This Email may contain confidential or privileged information for the intended recipient (s) If you are not the intended recipient, please do not use or disseminate the information, notify the sender and delete it from your system.

______________________________________________________________________
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
