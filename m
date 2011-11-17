From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: [PATCH] Fix wrong parameter given to sizeof call
Date: Thu, 17 Nov 2011 21:33:52 +0100
Message-ID: <4EC56FB0.3040900@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from re04.intra2net.com ([82.165.46.26]:40938 "EHLO
	re04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752250Ab1KQUdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 15:33:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"remote_list" is of type

struct dma_chunk remote_list[VETH_MAX_FRAMES_PER_MSG];

Probably a copy'n'paste error.

Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
---
 drivers/net/ethernet/ibm/iseries_veth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/ibm/iseries_veth.c b/drivers/net/ethernet/ibm/iseries_veth.c
index 4326681..acc31af 100644
--- a/drivers/net/ethernet/ibm/iseries_veth.c
+++ b/drivers/net/ethernet/ibm/iseries_veth.c
@@ -1421,7 +1421,7 @@ static void veth_receive(struct veth_lpar_connection *cnx,
 
 		/* FIXME: do we need this? */
 		memset(local_list, 0, sizeof(local_list));
-		memset(remote_list, 0, sizeof(VETH_MAX_FRAMES_PER_MSG));
+		memset(remote_list, 0, sizeof(remote_list));
 
 		/* a 0 address marks the end of the valid entries */
 		if (senddata->addr[startchunk] == 0)
-- 
1.7.6.4
