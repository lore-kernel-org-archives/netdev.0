From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/6] nfp: cleanups and improvements
Date: Sat, 16 Apr 2016 11:25:48 +0100
Message-ID: <1460802354-14248-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37242 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163AbcDPK0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 06:26:21 -0400
Received: by mail-wm0-f45.google.com with SMTP id n3so62926968wmn.0
        for <netdev@vger.kernel.org>; Sat, 16 Apr 2016 03:26:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Main purpose of this set is to get rid of doing potentially long
mdelay()s but it also contains some trivial changes I've accumulated.
First two patches fix harmless copy-paste errors, next two clean up
the documentation and remove unused defines.  Patch 5 clarifies the
interpretation of RX descriptor fields.  Patch 6, by far the biggest,
adds ability to perform FW reconfig asynchronously thanks to which
we can stop using mdelay().


Jakub Kicinski (6):
  nfp: check the right pointer for errors
  nfp: remove unnecessary static
  nfp: correct names of constants in comments
  nfp: remove unused suspicious mask defines
  nfp: remove buggy RX buffer length validation
  nfp: add async reconfiguration mechanism

 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  12 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 198 +++++++++++++++++----
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |  10 +-
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |   4 +-
 4 files changed, 176 insertions(+), 48 deletions(-)

-- 
1.9.1
