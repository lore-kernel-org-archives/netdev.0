From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: pull-request: ieee802154 2017-09-20
Date: Thu, 21 Sep 2017 22:56:07 +0200
Message-ID: <20170921205606.GA14244@work.Speedport_W_724V_09011603_05_010>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wpan@vger.kernel.org, alex.aring@gmail.com,
        marcel@holtmann.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:35172
        "EHLO osg.samsung.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751728AbdIUU4U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 16:56:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave.

[Resend with netdev in cc]

Here comes a pull request for ieee802154 changes I have queued up for
this merge window.

Normally these have been coming through the bluetooth tree but as this
three have been falling through the cracks so far and I have to review
and ack all of them anyway I think it makes sense if I save the
bluetooth people some work and handle them directly.

Its the first pull request I send to you so please let me know if I did
something wrong or if you prefer a different format.

regards
Stefan Schmidt

The following changes since commit 8ca712c373a462cfa1b62272870b6c2c74aa83f9:

  Merge branch 'net-speedup-netns-create-delete-time' (2017-09-19 16:32:24 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/sschmidt/wpan-next.git ieee802154-for-davem-2017-09-20

for you to fetch changes up to d5dd29e4dafef4baad7bf529ad73cafeb13e1aa8:

  ieee802154: atusb: Driver for Busware HUL dongle (2017-09-20 13:37:16 +0200)

----------------------------------------------------------------
Support for the hulusb hardware inside the atusb driver by Josef
Filzmaier and 802.15.4 MAC security compliance fix by Diogenes Pereira.
----------------------------------------------------------------
Diogenes Pereira (2):
      mac802154: replace hardcoded value with macro
      mac802154: Fix MAC header and payload encrypted

Josef Filzmaier (1):
      ieee802154: atusb: Driver for Busware HUL dongle

 drivers/net/ieee802154/atusb.c | 317 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----------------
 drivers/net/ieee802154/atusb.h |   8 ++++
 net/mac802154/llsec.c          |  14 ++++--
 3 files changed, 295 insertions(+), 44 deletions(-)
