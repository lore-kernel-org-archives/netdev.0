From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] phy: SMSC: fix unused warnings when built into kernel
Date: Fri, 6 Aug 2010 14:43:46 +0800
Message-ID: <AANLkTi=_-ZZ8nyFLiBKSWNTcM_SkwLe2-ZL17zBQb0i4@mail.gmail.com>
References: <1281076034-17390-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34514 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962Ab0HFGoH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 02:44:07 -0400
Received: by wyb39 with SMTP id 39so7439835wyb.19
        for <netdev@vger.kernel.org>; Thu, 05 Aug 2010 23:44:06 -0700 (PDT)
In-Reply-To: <1281076034-17390-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 6, 2010 at 2:27 PM, Mike Frysinger <vapier@gentoo.org> wrot=
e:
> If the SMSC phy is not built as a module, we get the warning:
> =A0 =A0 =A0 =A0drivers/net/phy/smsc.c:257: warning: 'smsc_tbl' define=
d but not used
>
> So mark the structure as maybe unused to avoid this.
>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
> =A0drivers/net/phy/smsc.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
> index 78fa988..11944ef 100644
> --- a/drivers/net/phy/smsc.c
> +++ b/drivers/net/phy/smsc.c
> @@ -254,7 +254,7 @@ MODULE_LICENSE("GPL");
> =A0module_init(smsc_init);
> =A0module_exit(smsc_exit);
>
> -static struct mdio_device_id smsc_tbl[] =3D {
> +static __maybe_unused struct mdio_device_id smsc_tbl[] =3D {
> =A0 =A0 =A0 =A0{ 0x0007c0a0, 0xfffffff0 },
> =A0 =A0 =A0 =A0{ 0x0007c0b0, 0xfffffff0 },
> =A0 =A0 =A0 =A0{ 0x0007c0c0, 0xfffffff0 },

How about adding a #ifdef CONFIG_SMSC_PHY_MODULE clause  around these l=
ines?

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
