From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net v2 0/3] netvsc: bug fixes
Date: Wed,  7 Jun 2017 15:53:46 -0700
Message-ID: <20170607225349.28359-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34578 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751433AbdFGWx6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 18:53:58 -0400
Received: by mail-pf0-f170.google.com with SMTP id 9so10404755pfj.1
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 15:53:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are bugfixes for netvsc driver in 4.12.

Stephen Hemminger (3):
  netvsc: fix rcu dereference warning from ethtool
  netvsc: fix net poll mode
  netvsc: move filter setting to rndis_device

 drivers/net/hyperv/hyperv_net.h   |  5 ++--
 drivers/net/hyperv/netvsc_drv.c   | 54 +++++++++++++--------------------------
 drivers/net/hyperv/rndis_filter.c | 30 +++++++++++++++++++++-
 3 files changed, 50 insertions(+), 39 deletions(-)

Note: trying out some scripting to check for obvious issues,
build, test, then send email. Eventually want to expand it to
spin up full test rig on Azure.

Please let me know if there are any issues.
The good part about scripting is that it does the same thing everytime;
the bad part is that it will make the same mistakes everytime.

-- 
2.11.0
