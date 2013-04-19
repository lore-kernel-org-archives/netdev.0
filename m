From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net,stable 0/3] qmi_wwan: working around 3 serious
 firmware bugs
Date: Fri, 19 Apr 2013 17:51:56 -0400 (EDT)
Message-ID: <20130419.175156.87420722153479024.davem@davemloft.net>
References: <1366325831-13727-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1366325831-13727-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Fri, 19 Apr 2013 00:57:08 +0200

> This series adds workarounds for 3 different firmware bugs, each
> preventing the affected devices from working at all. I therefore
> humbly request that these fixes go to stable-3.8 (if still
> maintained) and 3.9 (either via net if still possible, or via
> stable if not).
>=20
> All 3 workarounds are applied to all devices supported by the driver.
> Adding quirks for specific devices was considered as an alternative,
> but was rejected because we have too little information about the
> exact distribution of the buggy firmwares. All we know is that the
> same bug shows up in devices from at least 3 different, and presumabl=
y
> independent, vendors.
>=20
> The workarounds have instead been designed to automatically apply
> when necessary, and to have as little impact as possible on unaffecte=
d
> devices.  The series has been tested on a number of devices both with
> and without these bugs.
>=20
> The series should apply cleanly to net/master, net-next/master and
> stable/linux-3.8.y

Series applied and queued up for -stable, thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
