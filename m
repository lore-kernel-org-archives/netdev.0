From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: Re: [PATCH v2 04/46] net/wireless: p54: remove useless dma_sync_single_for_device(DMA_FROM_DEVICE)
Date: Mon, 11 Jul 2011 11:15:20 -0400
Message-ID: <4E1B1388.4060500@gnu.org>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl> <86c8bde08b005ca7eb4806ea77aec1f3212d63fc.1310339688.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <86c8bde08b005ca7eb4806ea77aec1f3212d63fc.1310339688.git.mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/10/2011 08:52 PM, Micha=C5=82 Miros=C5=82aw wrote:
> Also constify pointers used in frame parsers to verify assumptions.

Cleanups are better done separately.

> -	u16 type =3D le16_to_cpu(*((__le16 *)skb->data));
> +	u16 type =3D le16_to_cpu(*(const __le16 *)skb->data);

I think it would be more appropriate to use get_unaligned_le16() here.=20
No casts should be needed then.

That's not an objection, just a suggestion :)

--=20
Regards,
Pavel Roskin
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
