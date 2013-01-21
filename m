From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net 0/3] cdc_ncm and cdc_mbim fixes for 3.8
Date: Mon, 21 Jan 2013 16:50:37 +0100
Message-ID: <1358783440-11459-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The 2 first patches in this series are required to make the Sierra
Wireless MC7710 card work in MBIM mode.  They may also be
required for other Qualcomm firmware based MBIM devices.

Patch #1 was previously posted as a standalone patch.  This version
is a replacement, removing a theoretical NULL pointer exception.=20

Patch #3 fixes a bug I introduced in v3.7

Bj=C3=B8rn Mork (3):
  net: cdc_ncm: workaround for missing CDC Union
  net: cdc_mbim: send ZLP after max sized NTBs
  net: cdc_ncm: fix error path for single interface probing

 drivers/net/usb/cdc_mbim.c |    2 +-
 drivers/net/usb/cdc_ncm.c  |   30 +++++++++++++++++++++++++++++-
 2 files changed, 30 insertions(+), 2 deletions(-)

--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
