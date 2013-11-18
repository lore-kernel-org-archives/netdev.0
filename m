From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 0/2] be2net: Patch series
Date: Mon, 18 Nov 2013 10:44:12 -0600
Message-ID: <20131118164412.GA3016@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:28758 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321Ab3KRQoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 11:44:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply these two patches.

Ajit Khaparde (2):
  be2net: Fix unconditional enabling of Rx interface options
  be2net: Delete secondary unicast MAC addresses during be_close

 drivers/net/ethernet/emulex/benet/be_cmds.c | 16 ++++++++++++++--
 drivers/net/ethernet/emulex/benet/be_cmds.h |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c |  7 ++++++-
 3 files changed, 21 insertions(+), 4 deletions(-)

-- 
1.8.1.2
