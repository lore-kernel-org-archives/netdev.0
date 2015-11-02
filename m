From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net,stable] qmi_wwan: fix entry for HP lt4112 LTE/HSPA+
 Gobi 4G Module
Date: Mon, 02 Nov 2015 15:59:53 -0500 (EST)
Message-ID: <20151102.155953.573501974172839058.davem@davemloft.net>
References: <1446338090-16494-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1446338090-16494-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Sun,  1 Nov 2015 01:34:50 +0100

> The lt4112 is a HP branded Huawei me906e modem. Like other Huawei
> modems, it does not have a fixed interface to function mapping.
> Instead it uses a Huawei specific scheme: functions are mapped by
> subclass and protocol.
>=20
> However, the HP vendor ID is used for modems from many different
> manufacturers using different schemes, so we cannot apply a generic
> vendor rule like we do for the Huawei vendor ID.
>=20
> Replace the previous lt4112 entry pointing to an arbitrary interface
> number with a device specific subclass + protocol match.
>=20
> Reported-and-tested-by: Muri Nicanor <muri+libqmi-8Y1gJgr9kN5yDzI6CaY1VQ@public.gmane.org>
> Tested-by: Martin Hauke <mardnh-Mmb7MZpHnFY@public.gmane.org>
> Fixes: bb2bdeb83fb1 ("qmi_wwan: Add support for HP lt4112 LTE/HSPA+ G=
obi 4G Modem")
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

Applied and queued up for -stable, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
