From: Samuel Ortiz <samuel@sortiz.org>
Subject: [GIT] IrDA pull request for 2.6.31-rc1
Date: Sat, 13 Jun 2009 02:47:13 +0200
Message-ID: <1244854033.3422.23.camel@sortiz-mobl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@vger.kernel.org,
	irda-users@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33943 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbZFMApE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 20:45:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This is a pull request for the 2.6.31 merge window, for the IrDA subsystem.
It's basically the blackfin driver, a wait counter fix and me advertising the
new IrDA git tree.
I hope it's not too late for making it to rc1 through your net-next-2.6 tree.

Here goes the pull request:

The following changes since commit 8981f01001c616f58f1623ecadfab8b1ed758da7:
  Herbert Xu (1):
        virtio_net: Fix IP alignment on non-mergeable RX path

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/sameo/irda-2.6.git for-next

Graff Yang (1):
      irda: new Blackfin on-chip SIR IrDA driver

Roel Kluin (1):
      irda: smsc wait count reaches -1

Samuel Ortiz (1):
      irda: add git tree to MAINTAINERS file

MAINTAINERS                   |    1 +
drivers/net/irda/Kconfig      |   45 +++
drivers/net/irda/Makefile     |    1 +
drivers/net/irda/bfin_sir.c   |  820 +++++++++++++++++++++++++++++++++++++++++
drivers/net/irda/bfin_sir.h   |  148 ++++++++
drivers/net/irda/smsc-ircc2.c |    2 +-
6 files changed, 1016 insertions(+), 1 deletions(-)
create mode 100644 drivers/net/irda/bfin_sir.c
create mode 100644 drivers/net/irda/bfin_sir.h


