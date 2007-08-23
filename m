From: Willy Tarreau <w@1wt.eu>
Subject: [PATCH] fix realtek phy id in forcedeth
Date: Thu, 23 Aug 2007 21:27:09 +0200
Message-ID: <20070823192709.GA22729@1wt.eu>
References: <20070822083844.%N@1wt.eu> <20070822204225.GD14132@1wt.eu> <20070822230526.GC32121@suse.de> <200708231750.45257.prakash@punnoor.de> <20070823165513.GA6341@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Prakash Punnoor <prakash@punnoor.de>, Greg KH <gregkh@suse.de>,
	stable@kernel.org, netdev@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	linux-kernel@vger.kernel.org, Chuck Ebbert <cebbert@redhat.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2287 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752579AbXHWTp1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2007 15:45:27 -0400
Content-Disposition: inline
In-Reply-To: <20070823165513.GA6341@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Greg,

On Thu, Aug 23, 2007 at 09:55:13AM -0700, Greg KH wrote:
> It might help if someone sends a real patch that can be applied :)

This is getting really silly now :-) We're all wasting more time
wondering who will send the patch than posting it. I've lost, I got
fed up first, so here it is. Please apply to mainline then stable.

Thanks,
Willy

--

>From a0e2922b99eedd9863232368ea2afe072c52783e Mon Sep 17 00:00:00 2001
From: Willy Tarreau <w@1wt.eu>
Date: Thu, 23 Aug 2007 21:35:41 +0200
Subject: [PATCH] fix realtek phy id in forcedeth

As noticed by Chuck Ebbert, commit c5e3ae8823693b260ce1f217adca8add1bc0b3de
introduced a copy-paste typo, as realtek phy is 0x732 and not 0x1c1. Obvious
fix below suggested by Ayaz Abdulla.

Signed-off-by: Willy Tarreau <w@1wt.eu>
Cc: Ayaz Abdulla <aabdulla@nvidia.com>
Cc: Chuck Ebbert <cebbert@redhat.com>
---
 drivers/net/forcedeth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 10f4e3b..1938d6d 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -552,7 +552,7 @@ union ring_type {
 #define PHY_OUI_MARVELL	0x5043
 #define PHY_OUI_CICADA	0x03f1
 #define PHY_OUI_VITESSE	0x01c1
-#define PHY_OUI_REALTEK	0x01c1
+#define PHY_OUI_REALTEK	0x0732
 #define PHYID1_OUI_MASK	0x03ff
 #define PHYID1_OUI_SHFT	6
 #define PHYID2_OUI_MASK	0xfc00
-- 
1.5.2.5

