From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH 0/3] caif: CAIF for CDC NCM USB
Date: Fri,  2 Dec 2011 15:06:14 +0100
Message-ID: <1322834777-2486-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Alexey Orishko <alexey.orishko@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56374 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756602Ab1LBOG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 09:06:28 -0500
Received: by faaq16 with SMTP id q16so2045852faa.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 06:06:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches enables sending and receive CAIF packets
over a cdc_ncm usb interface.

The patches has been tested on real HW and we have been running with th=
is
for more than 6 months now.

NCM 1.0 does not support anything but Ethernet framing, hence
CAIF payload will be put into Ethernet frames. This it's a little
quirky. The long term solution for NCM should be based on
MBIM 1.0 specification.

Thanks,
Sjur Br=C3=A6ndeland


Sjur Br=C3=A6ndeland (3):
  if_ether.h: Add IEEE 802.1 Local Experimental Ethertype 1.
  caif: Add support for flow-control on device's tx-queue
  caif: Add support for CAIF over CDC NCM USB interface

 include/linux/if_ether.h  |    1 +
 include/net/caif/cfusbl.h |   13 +++
 net/caif/Kconfig          |   11 +++
 net/caif/Makefile         |    4 +-
 net/caif/caif_dev.c       |   55 +++++++++++++
 net/caif/cfusbl.c         |  199 +++++++++++++++++++++++++++++++++++++=
++++++++
 6 files changed, 282 insertions(+), 1 deletions(-)
 create mode 100644 include/net/caif/cfusbl.h
 create mode 100644 net/caif/cfusbl.c
