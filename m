From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH 0/3] igb: cleanup and code deduplication
Date: Tue, 29 Mar 2011 15:09:43 +0200
Message-ID: <1301404186-20872-1-git-send-email-sassmann@kpanic.de>
Cc: e1000-devel@lists.sourceforge.net, jeffrey.t.kirsher@intel.com,
	alexander.h.duyck@intel.com, sassmann@kpanic.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44255 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752988Ab1C2NJ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2011 09:09:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some cleanups for igb.
First patch is just a simple typo fix.
Second patch turns igb_update_nvm_checksum and igb_validate_nvm_checksum
into wrapper functions to deduplicate code.
Third patch puts the thermal sensor code into a function. This patch could use
some testing as I couldn't really test it due to lack of hardware.

  Stefan

Stefan Assmann (3):
  igb: fix typo in igb_validate_nvm_checksum_82580
  igb: transform igb_{update,validate}_nvm_checksum into wrappers of
    their *_with_offset equivalents
  igb: introduce igb_thermal_sensor_event for sensor checking

 drivers/net/igb/e1000_82575.c |   79 ++--------------------------------------
 drivers/net/igb/e1000_nvm.c   |   38 +++++++++++++++----
 drivers/net/igb/e1000_nvm.h   |    2 +
 drivers/net/igb/igb_main.c    |   67 +++++++++++++++++-----------------
 4 files changed, 70 insertions(+), 116 deletions(-)

-- 
1.7.4

