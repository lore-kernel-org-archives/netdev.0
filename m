From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000e: Drop a useless statement
Date: Wed, 21 Jul 2010 13:37:28 -0700
Message-ID: <AANLkTikpRSHZa22OwgvSy8WDn42kA=ZEqw=jiiTzm=8j@mail.gmail.com>
References: <201007201730.42852.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:57639 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753020Ab0GUUh3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 16:37:29 -0400
Received: by yxg6 with SMTP id 6so21838yxg.19
        for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 13:37:28 -0700 (PDT)
In-Reply-To: <201007201730.42852.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 20, 2010 at 08:30, Jean Delvare <jdelvare@suse.de> wrote:
> err is set again a few lines below.
>
> Signed-off-by: Jean Delvare <jdelvare@suse.de>
> Cc: Auke Kok <auke-jan.h.kok@intel.com>
> Cc: Bruce Allan <bruce.w.allan@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> ---
> I sent this patch to the e1000-devel list on June 8th, 2010, but
> didn't receive any answer:
> http://sourceforge.net/mailarchive/forum.php?thread_name=3D2010060818=
20.25381.jdelvare%40suse.de&forum_name=3De1000-devel
>
> =C2=A0drivers/net/e1000e/netdev.c | =C2=A0 =C2=A02 --
> =C2=A01 file changed, 2 deletions(-)
>
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -5557,8 +5557,6 @@ static int __devinit e1000_probe(struct
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_sw_in=
it;
>
> - =C2=A0 =C2=A0 =C2=A0 err =3D -EIO;
> -
> =C2=A0 =C2=A0 =C2=A0 =C2=A0memcpy(&hw->mac.ops, ei->mac_ops, sizeof(h=
w->mac.ops));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0memcpy(&hw->nvm.ops, ei->nvm_ops, sizeof(h=
w->nvm.ops));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0memcpy(&hw->phy.ops, ei->phy_ops, sizeof(h=
w->phy.ops));
>
> --
> Jean Delvare
> Suse L3

Thanks Jean, sorry for the delayed response.  I have added the patch
to my queue.

--=20
Cheers,
Jeff
