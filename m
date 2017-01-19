From: Roi Dayan <roid@mellanox.com>
Subject: [PATCH iproute2 0/2] two small fixes in flower option parser error flow
Date: Thu, 19 Jan 2017 14:31:18 +0200
Message-ID: <1484829080-18593-1-git-send-email-roid@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Paul Blakey <paulb@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57974 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752411AbdASMbh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 07:31:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

the first adds a missing return check and the second removes
an incorrect error msg.

Thanks,
Roi


Roi Dayan (2):
  tc: flower: Add missing err check when parsing flower options
  tc: flower: Fix incorrect error msg about eth type

 tc/f_flower.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)
