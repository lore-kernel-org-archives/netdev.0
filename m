From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Fri, 12 Sep 2008 16:26:53 -0700 (PDT)
Message-ID: <20080912.162653.14833095.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55557
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751788AbYILX07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 19:26:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) When NIU driver resets the chip after an error, it doesn't
   reset the buffer pointers in the TX and RX rings, which
   hangs the machine.  Fix from Santwona Behera

2) nla_ok() has a signedness bug that causes us to reference
   memory past the end of the attribute array in certain
   circumstances.  Fix from Vegard Nossum.

3) Bluetooth link policy regression fix from Marcel Holtmann.

4) ATH9K wireless sequence number handling bug fix from Jouni Malinen.

Please pull, thanks a lot!

The following changes since commit e550dfb0c2c31b6363aa463a035fc9f8dcaa3c9b:
  Neil Horman (1):
        ipv6: Fix OOPS in ip6_dst_lookup_tail().

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../holtmann/bluetooth-2.6

Jouni Malinen (1):
      ath9k: Assign seq# when mac80211 requests this

Marcel Holtmann (1):
      [Bluetooth] Fix regression from using default link policy

Santwona Behera (1):
      niu: panic on reset

Vegard Nossum (1):
      netlink: fix overrun in attribute iteration

 drivers/net/niu.c                   |   56 +++++++++++++++++++++++++++++++++++
 drivers/net/wireless/ath9k/beacon.c |   13 ++++++++
 drivers/net/wireless/ath9k/core.h   |    1 +
 drivers/net/wireless/ath9k/main.c   |   14 +++++++++
 include/net/netlink.h               |    2 +-
 net/bluetooth/hci_core.c            |    3 ++
 6 files changed, 88 insertions(+), 1 deletions(-)

