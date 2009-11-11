From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 13/13] pcmcia: rework the irq_req_t typedef
Date: Wed, 11 Nov 2009 21:46:03 +0100
Message-ID: <1257972363.21467.7.camel@violet>
References: <20091111203303.GA7939@comet.dominikbrodowski.net>
	 <1257971899-9274-13-git-send-email-linux@dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-pcmcia-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org, Jaroslav Kysela <perex-/Fr2/VpizcU@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Karsten Keil <isdn-iHCpqvpFUx0uJkBD2foKsQ@public.gmane.org>
To: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1257971899-9274-13-git-send-email-linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dominik,

> Most of the irq_req_t typedef'd struct can be re-worked quite
> easily:
> 
> (1) IRQInfo2 was unused in any case, so drop it.
> 
> (2) IRQInfo1 was used write-only, so drop it.
> 
> (3) Instance (private data to be passed to the IRQ handler):
> 	Most PCMCIA drivers using pcmcia_request_irq() to actually
> 	register an IRQ handler set the "dev_id" to the same pointer
> 	as the "priv" pointer in struct pcmcia_device. Modify the two
> 	exceptions (ipwireless, ibmtr_cs) to also work this waym and
> 	set the IRQ handler's "dev_id" to p_dev->priv unconditionally.
> 
> (4) Handler is to be of type irq_handler_t.
> 
> (5) Handler != NULL already tells whether an IRQ handler is present.
> 	Therefore, we do not need the IRQ_HANDLER_PRESENT flag in
> 	irq_req_t.Attributes.
> 
> CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org
> CC: Jaroslav Kysela <perex-/Fr2/VpizcU@public.gmane.org>
> CC: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
> CC: Karsten Keil <isdn-iHCpqvpFUx0uJkBD2foKsQ@public.gmane.org>
> Signed-off-by: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
> ---
>  drivers/ata/pata_pcmcia.c                        |    1 -
>  drivers/bluetooth/bluecard_cs.c                  |    4 +---
>  drivers/bluetooth/bt3c_cs.c                      |    4 +---
>  drivers/bluetooth/btuart_cs.c                    |    4 +---
>  drivers/bluetooth/dtl1_cs.c                      |    4 +---

for the Bluetooth parts:

Acked-by: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>

Regards

Marcel
