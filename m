From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH v2 0/2] net: start kdoc'ifying net_device
Date: Tue, 25 Feb 2014 17:15:11 -0800
Message-ID: <1393377313-28695-1-git-send-email-mcgrof@do-not-panic.com>
Cc: f.fainelli@gmail.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>
To: ben@decadent.org.uk, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While working on extending some functionality I felt restricted
with the amount of documentation I can add. Part of this is that
the existing style on the header files don't let me be verbose.
This starts addressing that by using kdoc for the net_device
flags, and as Ben noted, the priv_flags can be moved out from
UAPI.

Luis R. Rodriguez (2):
  net: kdoc struct net_device flags and priv_flags
  net: move net_device priv_flags out from UAPI

 include/linux/netdevice.h |  83 ++++++++++++++++++++++++++++
 include/uapi/linux/if.h   | 134 +++++++++++++++++++++++++++-------------------
 2 files changed, 163 insertions(+), 54 deletions(-)

-- 
1.8.5.3
