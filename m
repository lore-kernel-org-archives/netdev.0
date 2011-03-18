From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 0/6] be2net: patch series
Date: Fri, 18 Mar 2011 18:50:56 +0530
Message-ID: <eab3659e-09dd-4571-8dfe-faabfc6c2035@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:9934 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754261Ab1CRNVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 09:21:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply. Thanks!

Sathya Perla(6):
  be2net: refactor code that decides adapter->num_rx_queues
  be2net: fix to not drop unfiltered vlan pkts
  be2net: parse vid and vtm fields of rx-compl only if vlanf bit is set
  be2net: remove redundant code in be_worker()
  be2net: cancel be_worker() in be_shutdown() even when i/f is down
  be2net: remove one useless line

 drivers/net/benet/be.h      |    8 ++-
 drivers/net/benet/be_main.c |  119 ++++++++++++++++++++++--------------------
 2 files changed, 67 insertions(+), 60 deletions(-)

