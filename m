From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH iproute2 0/4] Add support for dpipe's global header formatting
Date: Thu,  7 Sep 2017 17:26:39 +0300
Message-ID: <1504794403-45690-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, stephen@networkplumber.org, jiri@resnulli.us,
        mlxsw@mellanox.com, andrew@lunn.ch,
        Arkadi Sharshevsky <arkadis@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40308 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754005AbdIGOYH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 10:24:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some dpipe's global header values need special formatting, for example
Ethernet and IP addresses. This patchset adds support for IPv4/6 and
Ethernet's special format.

Arkadi Sharshevsky (4):
  devlink: Make match/action parsing more flexible
  devlink: Add support for special format protocol headers
  devlink: Update devlink UAPI file
  devlink: Add support for protocol IPv4/IPv6/Ethernet special formats

 devlink/devlink.c       | 319 +++++++++++++++++++++++++++++++++++++-----------
 include/linux/devlink.h |  18 +++
 2 files changed, 265 insertions(+), 72 deletions(-)

-- 
2.4.11
