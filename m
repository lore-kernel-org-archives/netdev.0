From: Sebastian.Poehn@Belden.com
Subject: [PATCH] ixgbe: RX ntuple feature must check num_rx_queues
Date: Tue, 10 May 2011 10:21:02 -0400
Message-ID: <OFA595D9DB.234DFCEB-ON8525788C.004ED485-8525788C.004ED485@BeldenCDT.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.belden.com ([12.161.118.90]:48791 "EHLO mx1.belden.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755514Ab1EJOVK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 10:21:10 -0400
In-Reply-To: 
References: 
MIME-Version: 1.0
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver must check how much RX queues there are, not TX queues.

--- ixgbe_ethtool.c.orig=A0=A0=A0 2011-05-10 16:18:00.313745560 +0200
+++ ixgbe_ethtool.c=A0=A0=A0 2011-05-10 16:18:23.285747635 +0200
@@ -2349,9 +2349,9 @@ static int ixgbe_set_rx_ntuple(struct ne
=A0
=A0=A0=A0=A0 /*
=A0=A0=A0=A0 =A0* Don't allow programming if the action is a queue grea=
ter than
-=A0=A0=A0 =A0* the number of online Tx queues.
+=A0=A0=A0 =A0* the number of online Rx queues.
=A0=A0=A0=A0 =A0*/
-=A0=A0=A0 if ((fs->action >=3D adapter->num_tx_queues) ||
+=A0=A0=A0 if ((fs->action >=3D adapter->num_rx_queues) ||
=A0=A0=A0=A0 =A0=A0=A0 (fs->action < ETHTOOL_RXNTUPLE_ACTION_DROP))
=A0=A0=A0=A0 =A0=A0=A0 return -EINVAL;

Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>

DISCLAIMER:

Privileged and/or Confidential information may be contained in this
message. If you are not the addressee of this message, you may not
copy, use or deliver this message to anyone. In such event, you
should destroy the message and kindly notify the sender by reply
e-mail. It is understood that opinions or conclusions that do not
relate to the official business of the company are neither given
nor endorsed by the company.

Thank You.

