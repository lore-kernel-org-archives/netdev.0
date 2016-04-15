From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net,stable] cdc_mbim: apply "NDP to end" quirk to all
 Huawei devices
Date: Thu, 14 Apr 2016 21:04:42 -0400 (EDT)
Message-ID: <20160414.210442.1510392839752405685.davem@davemloft.net>
References: <1460470272-9289-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	andreas.fett-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org, burdandrei-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1460470272-9289-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Tue, 12 Apr 2016 16:11:12 +0200

> We now have a positive report of another Huawei device needing
> this quirk: The ME906s-158 (12d1:15c1).  This is an m.2 form
> factor modem with no obvious relationship to the E3372 (12d1:157d)
> we already have a quirk entry for.  This is reason enough to
> believe the quirk might be necessary for any number of current
> and future Huawei devices.
>=20
> Applying the quirk to all Huawei devices, since it is crucial
> to any device affected by the firmware bug, while the impact
> on non-affected devices is negligible.
>=20
> The quirk can if necessary be disabled per-device by writing
> N to /sys/class/net/<iface>/cdc_ncm/ndp_to_end
>=20
> Reported-by: Andreas Fett <andreas.fett-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

Applied and queued up for -stable, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
