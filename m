From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: cdc_ncm: add Huawei devices
Date: Tue, 13 Nov 2012 14:34:19 -0500 (EST)
Message-ID: <20121113.143419.1681663503009222211.davem@davemloft.net>
References: <1352812783-741-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org,
	tommy7765-/E1597aS9LQAvxtiuMwx3w@public.gmane.org, olof.ermis-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1352812783-741-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Tue, 13 Nov 2012 14:19:43 +0100

> A number of Huawei 3G and LTE modems implement a CDC NCM function,
> including the necessary functional descriptors, but using a non
> standard interface layout and class/subclass/protocol codes.
>=20
> These devices can be handled by this driver with only a minor
> change to the probing logic, allowing a single combined control
> and data interface.  This works because the devices
> - include a CDC Union descriptor labelling the combined
>   interface as both master and slave, and
> - have an alternate setting #1 for the bulk endpoints on the
>   combined interface.
>=20
> The 3G/LTE network connection is managed by vendor specific AT
> commands on a serial function in the same composite device.
> Handling the managment function is out of the scope of this
> driver.  It will be handled by an appropriate USB serial
> driver.
>=20
> Reported-and-Tested-by: Olof Ermis <olof.ermis-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Reported-and-Tested-by: Tommy Cheng <tommy7765-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

Applied to net, thanks.

> I am therefore requesting that this patch is put in the stable
> queue like other device additons.
>=20
> I guess it may be too late for v3.7, but FWIW I have verified
> that the patch applies cleanly to both the current net-next/master
> and to net/master, and will not cause merge conflicts either way.
> I have also verified that it applies cleanly to the v3.6.6 stable
> release.

There were quite a few ID additions and I don't think most of them
were actually queued up for -stable submission.

Can you make a list of patches that still need to be submitted to
-stable, including this one?

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
