From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 0/3] nfp: fixes and trivial cleanup
Date: Wed,  7 Sep 2016 19:45:34 +0100
Message-ID: <1473273937-9230-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35561 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751810AbcIGSqU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 14:46:20 -0400
Received: by mail-wm0-f51.google.com with SMTP id i204so101039531wma.0
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 11:46:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

First patch drops unnecessary version.h includes.  Second one
drops support for pre-release versions of FW ABI.  Removing
FW ABI 0.0 from supported set is particularly good since 0
could just be uninitialized memory.  Last but not least I drop
unnecessary padding of frames on RX which makes us count bytes
incorrectly for the VF2VF traffic.

Jakub Kicinski (3):
  nfp: remove linux/version.h includes
  nfp: drop support for old firmware ABIs
  nfp: don't pad frames on receive

 drivers/net/ethernet/netronome/nfp/nfp_net_common.c  | 5 -----
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c | 1 -
 drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c  | 7 ++-----
 3 files changed, 2 insertions(+), 11 deletions(-)

-- 
1.9.1
