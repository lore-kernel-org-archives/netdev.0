From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 0/4] cdc_mbim: cleanups and new features
Date: Sun, 11 May 2014 00:17:19 +0200
Message-ID: <1399760243-26625-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Greg Suarez <gsuarez@smithmicro.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:51094 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753388AbaEJWRm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 May 2014 18:17:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series depends on commit 6b5eeb7f874b ("net: cdc_mbim: handle
unaccelerated VLAN tagged frames"), which is currently in "net" but
not yet in "net-next".

Patch 4 might have a minor context collision with the "cdc_ncm: add
buffer tuning and stats using ethtool" series I just posted for
review.  Please let me know if I should submit an adjusted version
in either direction.  These two series' are otherwise completely
independent of each other.

The major new feature here is in patch 1, which I hope will solve
some problems with the original design without changing the existing
API, optionally allowing IP session 0 to be treated like any other
MBIM session.

The rest are some minor cleanups and finally some documentation of
the current driver APIs, after this series has been applied.  I
started feeling a bit more mortal than usual lately, which probably
is healthy, and realized that I should put some of the stuff in my
head in a somewhat less volatile storage.



Bj=C3=B8rn Mork (4):
  net: cdc_mbim: optionally use VLAN ID 4094 for IP session 0
  net: cdc_mbim: reject IP packets on DSS VLANs
  net: cdc_mbim: add driver documentation
  net: cdc_ncm/cdc_mbim: rework probing of NCM/MBIM functions

 Documentation/networking/cdc_mbim.txt | 339 ++++++++++++++++++++++++++=
++++++++
 drivers/net/usb/cdc_mbim.c            | 119 +++++++++++-
 drivers/net/usb/cdc_ncm.c             |  27 ++-
 include/linux/usb/cdc_ncm.h           |   2 +-
 4 files changed, 464 insertions(+), 23 deletions(-)
 create mode 100644 Documentation/networking/cdc_mbim.txt

--=20
2.0.0.rc2
