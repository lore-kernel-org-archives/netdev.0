From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: PROBLEM: System hang when connecting USB modem (GCT/Yota LU150)
Date: Sun, 03 Apr 2016 15:18:22 +0200
Message-ID: <87h9fibzkx.fsf@nemi.mork.no>
References: <5700ED33.6020200@zoho.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Alex <alex3kov-ytc+IHgoah0@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5700ED33.6020200-ytc+IHgoah0@public.gmane.org> (Alex's message of "Sun, 3 Apr 2016
	13:15:15 +0300")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Alex <alex3kov-ytc+IHgoah0@public.gmane.org> writes:

> Apr 01 11:33:24 arch kernel: BUG: unable to handle kernel NULL pointe=
r dereference at 0000000000000003
> Apr 01 11:33:24 arch kernel: IP: [<ffffffffa0bc62a1>] usbnet_generic_=
cdc_bind+0x171/0x710 [cdc_ether]
=2E.
> Apr 01 11:33:24 arch kernel: Call Trace:
> Apr 01 11:33:24 arch kernel:  [<ffffffffa0bcf5b2>] generic_rndis_bind=
+0x62/0x520 [rndis_host]
> Apr 01 11:33:24 arch kernel:  [<ffffffff81499e82>] ? alloc_netdev_mqs=
+0x302/0x440
> Apr 01 11:33:24 arch kernel:  [<ffffffffa0bcfa83>] rndis_bind+0x13/0x=
20 [rndis_host]

This is most likely fixed by commit 29c6dd591bbd ("cdc-acm: fix NULL
pointer reference").  Which should defintely go into the 4.4 stable
series.  Could you please add it to your v4.4 queue, David?

Ignore the "cdc-acm" prefix. The patch fixes a NULL pointer dereference
in the cdc_ether/rndis_host drivers introduced by commit 823bd3433424
("cdc-ether: switch to common CDC parser")


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
