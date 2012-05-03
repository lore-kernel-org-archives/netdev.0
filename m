From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-next 2012-05-03
Date: Thu, 03 May 2012 13:17:07 -0400 (EDT)
Message-ID: <20120503.131707.112550136096227430.davem@davemloft.net>
References: <20120503152206.GL9285@tuxdriver.com>
	<20120503.130516.1008806127286088740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120503.130516.1008806127286088740.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Date: Thu, 03 May 2012 13:05:16 -0400 (EDT)

> Pulled, thanks John.

Actually, I un-pulled.  The bluetooth guys are sending crap code
formatting again.

>From 74e05692c9599866d5c8743764544cf77cd1af87 Mon Sep 17 00:00:00 2001
From: Andre Guedes <andre.guedes-430g2QfJUUCGglJvpFV4uA@public.gmane.org>
Date: Tue, 6 Mar 2012 19:37:06 -0300
Subject: [PATCH 007/160] Bluetooth: Check FINDING state in interleaved
 discovery

In order to do interleaved discovery we should be in DISCOVERY_
FINDING state. Otherwise, discovery should be stopped.

Signed-off-by: Andre Guedes <andre.guedes-430g2QfJUUCGglJvpFV4uA@public.gmane.org>
Signed-off-by: Gustavo F. Padovan <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
 ...
-		if (hdev->discovery.type == DISCOV_TYPE_INTERLEAVED) {
+		if (hdev->discovery.type == DISCOV_TYPE_INTERLEAVED &&
+				hdev->discovery.state == DISCOVERY_FINDING) {

Really, we went through this a million times very recently and I'm
not pulling anything into my tree that has garbage like this in it.

Sorry.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
