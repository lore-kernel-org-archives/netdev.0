From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: usb: qmi_wwan: New driver for Huawei QMI based
 WWAN devices
Date: Wed, 25 Jan 2012 17:00:36 -0500 (EST)
Message-ID: <20120125.170036.1730469043830544127.davem@davemloft.net>
References: <1327023442-4304-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1327023442-4304-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Fri, 20 Jan 2012 02:37:22 +0100

> Some WWAN LTE/3G devices based on chipsets from Qualcomm provide
> near standard CDC ECM interfaces in addition to the usual serial
> interfaces.   The Huawei E392/E398 are examples of such devices.
>=20
> These typically cannot be fully configured using AT commands
> over a serial interface.  It is necessary to speak the proprietary
> Qualcomm MSM Interface (QMI) protocol to the device to enable the
> ethernet proxy functionality.
>=20
> The devices embed the QMI protocol in CDC on the control interface,
> using standard CDC commands and notifications. The do not otherwise
> use CDC commands for the ethernet function.  This driver does
> therefore not need access to any other aspects of the control
> interface than the descriptors attached to it.
>=20
> Another driver, cdc-wdm, will provide userspace access to the
> QMI protocol independently of this driver.  To facilitate this,
> this driver avoids binding to the control interface, and uses
> only the associated data interface after parsing the common CDC
> functional descriptors on the control interface.
>=20
> You will want both the cdc-wdm and option drivers as companions to
> this driver, to have full access to all interfaces and protocols
> exported by the device.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
