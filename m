From: Roi Dayan <roid@mellanox.com>
Subject: [PATCH iproute2 0/2] Adding help and inline mode control to eswitch
Date: Sun, 27 Nov 2016 13:21:01 +0200
Message-ID: <1480245663-814-1-git-send-email-roid@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35860 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753768AbcK0LVW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 06:21:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The first patch is adding missing help message for eswitch.
The second patch is adding functionality to show/modify eswitch inline mode.

Thanks,
Roi


Roi Dayan (2):
  devlink: Add usage help for eswitch subcommand
  devlink: Add option to set and show eswitch inline mode

 devlink/devlink.c       |   89 +++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/devlink.h |    8 ++++
 man/man8/devlink-dev.8  |   21 ++++++++++-
 3 files changed, 115 insertions(+), 3 deletions(-)
