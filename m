From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: pull-request: wireless-drivers-next 2015-02-07
Date: Tue, 10 Feb 2015 15:49:24 +0200
Message-ID: <8761b9op0b.fsf@kamboji.qca.qualcomm.com>
References: <87a90qosos.fsf@kamboji.qca.qualcomm.com>
	<20150209.121342.1535841700027616341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150209.121342.1535841700027616341.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (David
	Miller's message of "Mon, 09 Feb 2015 12:13:42 -0800 (PST)")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:

> From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
> Date: Sat, 07 Feb 2015 13:40:51 +0200
>
>> There's a small conflict in drivers/net/wireless/rtlwifi/pci.c, the =
fix
>> is to leave the two labels like this:
>>=20
>> 			schedule_work(&rtlpriv->works.lps_change_work);
>> 		}
>> end:
>> 		skb =3D new_skb;
>> no_new:
>> 		if (rtlpriv->use_new_trx_flow) {
>>=20
>>=20
>
> That can't be the correct resolution:
>
> drivers/net/wireless/rtlwifi/pci.c: In function =E2=80=98_rtl_pci_rx_=
interrupt=E2=80=99:
> drivers/net/wireless/rtlwifi/pci.c:934:1: warning: label =E2=80=98end=
=E2=80=99 defined but not used [-Wunused-label]
>
> So I've removed that label in the merge commit.

Sorry about that, but great that you catched my mistake.

--=20
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
