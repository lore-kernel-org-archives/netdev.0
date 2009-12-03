From: Arnd Bergmann <arnd@arndb.de>
Subject: [RFC 0/2] macvtap, second try
Date: Thu,  3 Dec 2009 18:51:58 +0100
Message-ID: <1259862720-28432-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S . Miller \"" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@voltaire.com>,
	"Fischer, Anna" <anna.fischer@hp.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Patrick Mullaney <pmullaney@novell.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756251AbZLCRxv@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I did not get this ready for the merge window, but people asked what
the status of this is so I'm posting it now to solicit feedback.

The first patch just adds some hooks into macvlan.c and is less
invasive than the previous version. That part should be fine
and I'd like this to get merged into macvlan for 2.6.33 if people
agree that the approach is right.

The second patch adds the driver using it and is not ready for
integration unfortunately, but maybe it could get into staging
anyway. Please look at that patch carefully and provide feedback.

	Arnd <><
---

Arnd Bergmann (1):
  macvlan: add tap device backend

Patrick Mullaney (1):
  macvlan: Allow plugging in additional backends

 drivers/net/Kconfig        |   12 +
 drivers/net/Makefile       |    1 +
 drivers/net/macvlan.c      |  113 ++++-----
 drivers/net/macvtap.c      |  560 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/if_macvlan.h |   71 ++++++
 5 files changed, 693 insertions(+), 64 deletions(-)
 create mode 100644 drivers/net/macvtap.c
