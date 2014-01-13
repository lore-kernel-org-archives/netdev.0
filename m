From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/2] vxlan updates
Date: Mon, 13 Jan 2014 18:41:18 +0100
Message-ID: <1389634880-4138-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55958 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751316AbaAMRlX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jan 2014 12:41:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Did the split into two patches upon request from Cong Wang.

Changelog:

 v1->v2:
  - Removed BUG_ON as it's not needed.
 v2->v3:
  - Removed dev->reg_state check for netns.
 v3->v4:
  - Removed list_del(), we seem to do it in some places and
    in some others not; we agreed it's not really necessary.
  - Split patch into 2 patches, notifier part and module
    unload cleanup part.

Daniel Borkmann (2):
  net: vxlan: when lower dev unregisters remove vxlan dev as well
  net: vxlan: properly cleanup devs on module unload

 drivers/net/vxlan.c | 58 ++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 51 insertions(+), 7 deletions(-)

-- 
1.7.11.7
