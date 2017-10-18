From: Stefan Schmidt <stefan@datenfreihafen.org>
Subject: pull-request: ieee802154 2017-10-18
Date: Thu, 19 Oct 2017 00:03:33 +0200
Message-ID: <20171018220333.28378-1-stefan@datenfreihafen.org>
Cc: linux-wpan@vger.kernel.org, alex.aring@gmail.com,
        marcel@holtmann.org, netdev@vger.kernel.org,
        Stefan Schmidt <stefan@osg.samsung.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lasnet.de ([78.47.171.185]:56509 "EHLO
        proxima.lasnet.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750880AbdJRWDo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 18:03:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Schmidt <stefan@osg.samsung.com>

Hello Dave.

Please find below a pull request from the ieee802154 subsystem for net-next.

regards
Stefan Schmidt

The following changes since commit b9f1f1ce866c28e3d9b86202441b220244754a69:

  tcp: fix tcp_xmit_retransmit_queue() after rbtree introduction (2017-10-18 14:19:26 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/sschmidt/wpan-next.git ieee802154-for-davem-2017-10-18

for you to fetch changes up to 396665e8320987ff43b20a62a6a1cdae57aa1cc1:

  Merge remote-tracking branch 'net-next/master' (2017-10-18 17:40:18 +0200)

----------------------------------------------------------------
A warning fix from Colin King and a typo fix from Xue Liu. Bundled together with
a fixed firmware version check in the atusb driver.

----------------------------------------------------------------
Colin Ian King (1):
      ieee802154: atusb: make two structures static, fixes warnings

Stefan Schmidt (2):
      ieee802154: atusb: fix firmware version check to enable frame retries
      Merge remote-tracking branch 'net-next/master'

Xue Liu (1):
      ieee802154: netlink: fix typo of the name of struct genl_ops

 drivers/net/ieee802154/atusb.c | 8 +++-----
 net/ieee802154/netlink.c       | 6 +++---
 2 files changed, 6 insertions(+), 8 deletions(-)
