From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH 0/3 net-next] bnx2x: VLAN stripping toggle and a small cleanup
Date: Wed, 31 Aug 2011 17:00:33 +0200
Message-ID: <1314802836-9862-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vladz@broadcom.com, dmitry@broadcom.com, eilong@broadcom.com,
	mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17660 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755745Ab1HaPAn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 11:00:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
a couple of cleanups and the addition of the VLAN stripping toggle, upd=
ated
according to Vlad's and Micha=C5=82's feedback.

Michal Schmidt (3):
  bnx2x: remove TPA_ENABLE_FLAG
  bnx2x: do not set NETIF_F_LRO in bnx2x_init_bp
  bnx2x: expose HW RX VLAN stripping toggle

 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |   42 +++++++++++++-=
-------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   19 +++-------
 3 files changed, 32 insertions(+), 31 deletions(-)

--=20
1.7.6
