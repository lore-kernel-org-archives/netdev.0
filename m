From: Bert Kenward <bkenward@solarflare.com>
Subject: =?UTF-8?Q?[PATCH_net-next_0/5]_sfc:_additional_virtual_function_sup?=
 =?UTF-8?B?cG9ydOKAiw==?=
Date: Fri, 18 Dec 2015 17:07:54 +0000
Message-ID: <56743D6A.5020605@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:36228 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932467AbbLRRIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 12:08:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This introduces the client side of a mechanism to defer authorisation o=
f
operations, for example multicast subscription. Although primarily aime=
d at
SRIOV VFs this can also apply to unprivileged PFs.

Also handle reboot ordering corner cases better and reduce the level of=
 some
logging.

Bert Kenward (4):
  sfc: Retry MCDI after NO_EVB_PORT error on a VF
  sfc: Handle MCDI proxy authorisation
  sfc: Make failed filter removal less noisy
  sfc: Downgrade or remove some error messages

Tom=C3=A1=C5=A1 Pila=C5=99 (1):
  sfc: Downgrade EPERM messages from MCDI to debug

 drivers/net/ethernet/sfc/ef10.c |  68 +++++++----
 drivers/net/ethernet/sfc/efx.c  |   7 +-
 drivers/net/ethernet/sfc/mcdi.c | 252 ++++++++++++++++++++++++++++++++=
++++----
 drivers/net/ethernet/sfc/mcdi.h |  10 ++
 4 files changed, 290 insertions(+), 47 deletions(-)

--=20
2.4.3
