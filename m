From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH RFT net-next 0/4] via-rhine receive buffers rework
Date: Mon,  6 Apr 2015 20:01:48 +0200
Message-ID: <cover.1428340371.git.romieu@fr.zoreil.com>
Cc: "Nix" <nix@esperi.org.uk>, "David S. Miller" <davem@davemloft.net>,
	rl@hellgate.ch, "Bjarke Istrup Pedersen" <gurligebis@gentoo.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50039 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789AbbDFSCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 14:02:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an hopefully readable rework of my patch from two days ago.
It's different enough that it imho requires someone's Tested-by.

Patches #1..#3 are mostly there to slim patch #4. Patch #1 may make
some sense as a standalone fix though.

The series applies without error against v3.19 - what Nix uses - and
davem-next as of 5888b93b750609680735d6b8b737703083ef40ff ("Merge branch
'nf-hook-compress'").

Please test and review.

Francois Romieu (4):
  via-rhine: commit receive buffer address before descriptor status update.
  via-rhine: add allocation helpers.
  via-rhine: gotoize rhine_open error path.
  via-rhine: forbid holes in the receive descriptor ring.

 drivers/net/ethernet/via/via-rhine.c | 163 +++++++++++++++++++++--------------
 1 file changed, 100 insertions(+), 63 deletions(-)

-- 
2.1.0
