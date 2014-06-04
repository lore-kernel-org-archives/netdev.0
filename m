From: Andrew Ruder <andrew.ruder@elecsyscorp.com>
Subject: [PATCH 0/6] miscellaneous dm9000 driver fixes
Date: Wed,  4 Jun 2014 17:28:43 -0500
Message-ID: <cover.1401920320.git.andrew.ruder@elecsyscorp.com>
Cc: Andrew Ruder <andrew.ruder@elecsyscorp.com>,
	Joseph CHANG <josright123@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from new1-smtp.messagingengine.com ([66.111.4.221]:55710 "EHLO
	new1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751948AbaFDWh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 18:37:57 -0400
Received: from compute3.internal (compute3.nyi.mail.srv.osa [10.202.2.43])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id CA02232A
	for <netdev@vger.kernel.org>; Wed,  4 Jun 2014 18:29:12 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a collection of changes discovered while bringing a PXA270 based board
(Arcom ZEUS) with a Davicom DM9000A/B up to a more recent kernel (from 2.6.xx).
This addresses all of my earlier issues (August 2013) listed here:

http://marc.info/?l=linux-netdev&m=137598605603324&w=2

Andrew Ruder (6):
  dm9000: acquire irq flags from device tree
  dm9000: clean up reset code
  dm9000: clean up edge-triggered irq compatibility
  dm9000: remove redundant ISR status clear
  dm9000: handle initial link status
  dm9000: avoid sleeping in dm9000_timeout callback

 drivers/net/ethernet/davicom/dm9000.c | 68 +++++++++++++++++++++--------------
 1 file changed, 42 insertions(+), 26 deletions(-)

-- 
1.9.0.rc3.12.gbc97e2d
