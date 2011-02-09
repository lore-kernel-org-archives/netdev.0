From: Greg Lee <glee-list-wgPCUUL1U4vQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] USB CDC NCM errata updates for cdc_ncm host driver
Date: Wed, 9 Feb 2011 00:25:48 -0500
Message-ID: <AANLkTimRLLiYRRD1+zx0wxO2iy3G8e-kL6KcNigJF6wj@mail.gmail.com>
References: <1297107910-18263-1-git-send-email-alexey.orishko@stericsson.com> <1297107910-18263-2-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org, yauheni.kaliuta-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1297107910-18263-2-git-send-email-alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 7, 2011 at 2:45 PM, Alexey Orishko <alexey.orishko-Re5JQEeQqe8@public.gmane.org=
m> wrote:
>
> Specification links:
> - CDC NCM errata link:
> =A0http://www.usb.org/developers/devclass_docs/NCM10_012011.zip
> - CDC and WMC errata link:
> =A0http://www.usb.org/developers/devclass_docs/CDC1.2_WMC1.1_012011.z=
ip
>
> Changes:
> - driver updated to match cdc.h header with errata changes
> - added support for USB_CDC_SET_NTB_INPUT_SIZE control request with
> =A08 byte length
> - fixes to comply with specification: send only control requests supp=
orted by
> =A0device, set number of datagrams for IN direction, connection speed=
 structure
> =A0update, etc.
> - packet loss fixed for tx direction; misleading flag renamed.
> - adjusted hard_mtu value.
>
> Signed-off-by: Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>

Alexey (and others), are you aware of any commercially available
devices that implement NCM that we can test with?

Greg
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
