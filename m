From: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Subject: RE: [PATCH 1/2] usbnet: changes for upcoming cdc_ncm driver
Date: Wed, 24 Nov 2010 14:53:07 +0100
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520153BA879955A@EXDCVYMBSTM006.EQ1STM.local>
References: <1290531088-2393-1-git-send-email-alexey.orishko@stericsson.com>
 <D69C90565D53114396BF743585AF5A09122E61E8A3@VSHINMSMBX01.vshodc.lntinfotech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org" <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	"yauheni.kaliuta-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org" <yauheni.kaliuta-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	"balbi-l0cyMroinI0@public.gmane.org" <balbi-l0cyMroinI0@public.gmane.org>,
	Sjur BRENDELAND <sjur.brandeland-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>,
	Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: Viral Mehta <Viral.Mehta-oonXi/34qI7c+919tysfdA@public.gmane.org>,
	"gregkh-l3A5Bk7waGM@public.gmane.org" <gregkh-l3A5Bk7waGM@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <D69C90565D53114396BF743585AF5A09122E61E8A3-fVvhrSDAkVjuuPCCJ6VnObSn4PsL5ZDKvpI+GvaZM4lBDgjK7y7TUQ@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Viral Mehta [mailto:Viral.Mehta-oonXi/34qI7c+919tysfdA@public.gmane.org]
> Sent: 23 =CE=CF=D1=C2=D2=D1 2010 =C7. 18:40
> To: Alexey Orishko; gregkh-l3A5Bk7waGM@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org;
> yauheni.kaliuta-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org; felipe.balbi-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org; Sjur BRENDELAND;
> Alexey ORISHKO
> Subject: RE: [PATCH 1/2] usbnet: changes for upcoming cdc_ncm driver
>=20
> Hi,
>=20
> >Signed-off-by: Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
> >---
> >Changes:
> >drivers/net/usb/usbnet.c:
> >- the procedure of counting packets in usbnet was updated due to the
>  >accumulating of IP packets in the CDC NCM driver
> >- no short packets sent for cdc_ncm driver
> >include/linux/usb/usbnet.h:
> >- a new flag to indicate driver's capability to accumulate IP packet=
s
> in one
>  >skb before sending them (Tx direction)
>=20
> Feels like good to have these comments in comment log itself (i..e,
> above Signed-off-by line)
> Same for another patch as well.

No problem, I will repost it with comments above signed-off line

>=20
> Viral
>=20
> This Email may contain confidential or privileged information for the
> intended recipient (s) If you are not the intended recipient, please =
do
> not use or disseminate the information, notify the sender and delete =
it
> from your system.
>=20
> _____________________________________________________________________=
_
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
