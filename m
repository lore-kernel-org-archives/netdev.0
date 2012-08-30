From: Alan Ott <alan@signal11.us>
Subject: [PATCH v2 0/2] 6lowpan fixes
Date: Wed, 29 Aug 2012 22:38:59 -0400
Message-ID: <1346294341-26808-1-git-send-email-alan@signal11.us>
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Alan Ott <alan@signal11.us>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tony Cheneau <tony.cheneau@amnesiak.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes for 6lowpan.

I'm sorry about the other two emails that just went out with the same
subject.  One day I'm going to start getting these right on the first try.

Alan Ott (2):
  6lowpan: Make a copy of skb's delivered to 6lowpan
  6lowpan: handle NETDEV_UNREGISTER event

 net/ieee802154/6lowpan.c |   53 +++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 45 insertions(+), 8 deletions(-)
