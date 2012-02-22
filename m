From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 0/2] reuse eth_mac_addr()
Date: Wed, 22 Feb 2012 13:36:37 +0100
Message-ID: <1329914199-30862-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Sergey Lapin <slapin@ossfans.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Dillow <dave@thedillows.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two patches to remove custom .ndo_set_mac_address methodes
and use eth_mac_addr() instead since these functions to the 
same as eth_mac_addr(). 

An advantage of this change: eth_mac_addr() already
checks if the given mac address is valid. 

Danny Kukawka (2):
  3com/typhoon: reuse eth_mac_addr()
  net/ieee802154/6lowpan.c: reuse eth_mac_addr()

 drivers/net/ethernet/3com/typhoon.c |   14 +-------------
 net/ieee802154/6lowpan.c            |   16 ++--------------
 2 files changed, 3 insertions(+), 27 deletions(-)

-- 
1.7.8.3
