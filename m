From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 0/2] netvsc: fix module removal hangs
Date: Thu,  9 Mar 2017 15:04:13 -0800
Message-ID: <20170309230415.8854-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: kys@microsoft.com, haiyangz@microsoft.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33250 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751383AbdCIXEU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 18:04:20 -0500
Received: by mail-pf0-f172.google.com with SMTP id w189so34108611pfb.0
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 15:04:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A couple of patches are necessary to make netvsc driver module
removable again.

Stephen Hemminger (2):
  netvsc: need napi scheduled during removal
  netvsc: fix hang on netvsc module removal

 drivers/net/hyperv/netvsc.c | 20 ++++----------------
 1 file changed, 4 insertions(+), 16 deletions(-)

-- 
2.11.0
