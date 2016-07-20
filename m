From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 0/2] macsec: enable s/w offloads
Date: Wed, 20 Jul 2016 18:11:30 +0200
Message-ID: <cover.1469030596.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56779 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753248AbcGTQMV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 12:12:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patches leverage gro_cells infrastructure to enable both GRO and RPS
on macsec devices.

Paolo Abeni (2):
  gro_cells: gro_cells_receive now return error code
  macsec: enable GRO and RPS on macsec devices

 drivers/net/macsec.c    | 32 +++++++++++++++++++++++++-------
 include/net/gro_cells.h | 11 +++++------
 2 files changed, 30 insertions(+), 13 deletions(-)

-- 
1.8.3.1
