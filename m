From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 0/2] nfp: process MTU updates from firmware flower app
Date: Wed, 16 Aug 2017 09:37:42 +0200
Message-ID: <1502869064-25842-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36682 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751068AbdHPHhy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 03:37:54 -0400
Received: by mail-wm0-f47.google.com with SMTP id t201so24052184wmt.1
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 00:37:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first patch of this series moves processing of control messages from a
BH handler to a workqueue. That change makes it safe to process MTU
updates from the firmware which is added by the second patch of this
series.

Simon Horman (2):
  nfp: process control messages in workqueue in flower app
  nfp: process MTU updates from firmware flower app

 drivers/net/ethernet/netronome/nfp/flower/cmsg.c | 35 ++++++++++++++++++++++--
 drivers/net/ethernet/netronome/nfp/flower/cmsg.h |  1 +
 drivers/net/ethernet/netronome/nfp/flower/main.c | 14 ++++++++--
 drivers/net/ethernet/netronome/nfp/flower/main.h |  5 ++++
 4 files changed, 50 insertions(+), 5 deletions(-)

-- 
2.1.4
