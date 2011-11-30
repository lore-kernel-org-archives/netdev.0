From: =?UTF-8?q?Sjur=20Br=81=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [RFC 0/3] caif: Add support for CAIF over CDC NCM USB interface
Date: Wed, 30 Nov 2011 21:44:03 +0100
Message-ID: <1322685846-7790-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Alexey Orishko <alexey.orishko@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:52107 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896Ab1K3Uo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 15:44:29 -0500
Received: by eeuu47 with SMTP id u47so633125eeu.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 12:44:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

The following patches enables sending and receive CAIF packets
over a cdc_ncm usb interface.

The patches has been tested on real HW and we have been running with th=
is
for more than 6 months now.

NCM 1.0 does not support anything but Ethernet framing, hence
CAIF payload will be put into Ethernet frames. This it's a little
quirky, the long term solution for NCM should be based on
MBIM 1.0 specification.

These patches applies on top of previous patch-set:
commit 1014df0d3589ffc5dc881d0ca45164a482a55574
"Remove unused enum cfcnfg_phy_type and the parameter to cfserl_create.=
"

Review comments and feedback is welcome.

Thanks,
Sjur Br=C3=A6ndeland

Sjur Br=C3=A6ndeland (3):
  caif: Add support for flow-control on device's tx-queue
  if_ether.h: Add IEEE 802.1 Local Experimental Ethertype 1.
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
