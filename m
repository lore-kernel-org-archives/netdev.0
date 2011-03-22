From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 0/5] resending patch series minus one patch
Date: Tue, 22 Mar 2011 12:19:24 +0530
Message-ID: <cc416d6a-630e-41f2-a74e-22993cc1293d@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Sathya Perla <sathya.perla@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:5034 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753171Ab1CVGuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 02:50:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, I'm re-sending my previous patch series minus the "don't drop vlan
pkts" patch (I'll address this in a separate patch.)

Pls apply. Thanks.

Sathya Perla (5):
  be2net: refactor code that decides adapter->num_rx_queues
  be2net: parse vid and vtm fields of rx-compl only if vlanf bit is set
  be2net: remove redundant code in be_worker()
  be2net: cancel be_worker() in be_shutdown() even when i/f is down
  be2net: remove one useless line

 drivers/net/benet/be.h      |    8 ++-
 drivers/net/benet/be_main.c |  112 +++++++++++++++++++++++-------------------
 2 files changed, 66 insertions(+), 54 deletions(-)

