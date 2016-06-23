From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] wlcore: time sync : add support for 64 bit clock
Date: Thu, 23 Jun 2016 13:35:39 +0200
Message-ID: <1466681739.11061.3.camel@sipsolutions.net>
References: <20160623111332.23326-1-yanivma@ti.com>
	 (sfid-20160623_131215_419855_E4550AFE)
 <1466680680.11061.2.camel@sipsolutions.net>
	 <AE1C82FB3D0EC64DB1F752C81CBD1101391CF584@DFRE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, "Mishol, Guy" <guym-l0cyMroinI0@public.gmane.org>,
	Eliad Peller <eliad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Machani, Yaniv" <yanivma-l0cyMroinI0@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AE1C82FB3D0EC64DB1F752C81CBD1101391CF584-1tpBd5JUCm6IQmiDNMet8wC/G2K4zDHf@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> > Additionally, this looks like it changes the firmware API, so that=C2=
=A0
> > older firmware images will no longer work?
>=20
> It is backwards compatible,=C2=A0
> although it changes a API structure, older firmware are using only
> u16 for the field so there is no impact on that.
>=20

Oh, ok. I had also thought that the size changed, but missed that you
replaced a u32 with two u16. Thanks for checking :)

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
