From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 0/3] constify *_ops
Date: Wed, 23 Aug 2017 15:29:32 +0530
Message-ID: <1503482375-19983-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: davem@davemloft.net, Larry.Finger@lwfinger.net,
        chaoming_li@realsil.com.cn, kvalo@codeaurora.org,
        jon.maloy@ericsson.com, ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34747 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753799AbdHWJ7y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 05:59:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

*_ops are not supposed to change at runtime and none of the structures
is modified.

Arvind Yadav (3):
  [PATCH 1/3] net: rtlwifi: constify rate_control_ops
  [PATCH 2/3] net: rsi: mac80211: constify ieee80211_ops
  [PATCH 3/3] net: rsi: netlink: constify genl_ops

 drivers/net/wireless/realtek/rtlwifi/rc.c   | 2 +-
 drivers/net/wireless/rsi/rsi_91x_mac80211.c | 2 +-
 net/tipc/netlink_compat.c                   | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

-- 
1.9.1
