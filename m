From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 0/2] be2net: patch set
Date: Mon, 14 Apr 2014 16:12:39 +0530
Message-ID: <1397472161-28685-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:45467 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176AbaDNKjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 06:39:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1/2 is a v2 of a patch that was submitted earlier (as a part of a
different patch-set). v2 incorporates a suggestion given by David Laight
for how long to poll for pending TX completions while disabling a device.

Patch 2/2 fixes a crash in be_remove()->be_close()
path after be2net has aborted an EEH error recovery
due to a permanant failure.

Kalesh AP (1):
  be2net: Fix invocation of be_close() after be_clear()

Vasundhara Volam (1):
  be2net: Fix to reap TX compls till HW doesn't respond for some time

 drivers/net/ethernet/emulex/benet/be.h      |    1 +
 drivers/net/ethernet/emulex/benet/be_main.c |   17 +++++++++++++----
 2 files changed, 14 insertions(+), 4 deletions(-)
