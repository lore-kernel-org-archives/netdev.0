From: David Miller <davem@davemloft.net>
Subject: [GIT]: Wireless Networking
Date: Mon, 22 Sep 2008 16:17:01 -0700 (PDT)
Message-ID: <20080922.161701.159153918.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51471
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753543AbYIVXRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 19:17:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here are three wireless changes for 2.6.27.

The first two are critical fixes for the ATH9K driver that have been
making the rounds a lot lately (Linus, you even forwarded a reference
to at least one of them to John Linville and myself a few days ago).

And the third change is the addition of a new zd1121rw UDB device ID.

Linus, we also saw the zd1121rw OOPS you forward to us.  That bug is
only present in 2.6.26 and John Linville is getting the fix for that
one pushed to -stable.

Please pull, thanks a lot!

The following changes since commit cec5eb7be3a104fffd27ca967ee8e15a123050e2:
  Alan Cox (1):
        pcmcia: Fix broken abuse of dev->driver_data

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Senthil Balasubramanian (2):
      ath9k: connectivity is lost after Group rekeying is done
      ath9k: Fix IRQ nobody cared issue with ath9k

born.into.silence@gmail.com (1):
      wireless: zd1211rw: add device ID fix wifi dongle "trust nw-3100"

 drivers/net/wireless/ath9k/core.c      |    4 ++--
 drivers/net/wireless/ath9k/core.h      |    1 -
 drivers/net/wireless/ath9k/main.c      |   12 ++++++++----
 drivers/net/wireless/ath9k/xmit.c      |    6 +++---
 drivers/net/wireless/zd1211rw/zd_usb.c |    1 +
 5 files changed, 14 insertions(+), 10 deletions(-)
