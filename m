From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [PATCH] ath6kl: Unify sg_sz and buf_sz in ath6kl_sdio_alloc_prep_scat_req()
Date: Sat, 1 Jun 2013 15:17:14 +0300
Message-ID: <87fvx2nhyt.fsf@kamboji.qca.qualcomm.com>
References: <1366804954-20491-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <ath6kl-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
To: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1366804954-20491-1-git-send-email-geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org> (Geert
	Uytterhoeven's message of "Wed, 24 Apr 2013 14:02:34 +0200")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org> writes:

> sg_sz and buf_sz are initialized and used in a mutual exclusive way.
> However, some versions of gcc are not smart enough to see this:
>
> drivers/net/wireless/ath/ath6kl/sdio.c: In function =E2=80=98ath6kl_s=
dio_alloc_prep_scat_req=E2=80=99:
> drivers/net/wireless/ath/ath6kl/sdio.c:338: warning: =E2=80=98sg_sz=E2=
=80=99 may be used uninitialized in this function
>
> Unify the sg_sz and buf_sz variables into a single size variable to k=
ill
> the compiler warning.
>
> Signed-off-by: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>

Thanks, applied. Sorry for taking so long.

--=20
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
