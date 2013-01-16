From: Alan Ott <alan@signal11.us>
Subject: [PATCH 0/2] Handle Uncompressed IPv6 on 6LoWPAN
Date: Wed, 16 Jan 2013 00:43:55 -0500
Message-ID: <1358315037-10043-1-git-send-email-alan@signal11.us>
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Tony Cheneau <tony.cheneau@amnesiak.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alan Ott <alan@signal11.us>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This has been tested by exchanging data with with the Contiki operating
system using a Redwire Econotag.  Contiki had to be set to send uncompressed
data, and had to have a #define modified to enable reception and processing
of header-compressed packets when not set to send compressed data.

Alan Ott (2):
  6lowpan: Refactor packet delivery into a function
  6lowpan: Handle uncompressed IPv6 packets over 6LoWPAN

 net/ieee802154/6lowpan.c | 79 ++++++++++++++++++++++++++++++++++--------------
 1 file changed, 56 insertions(+), 23 deletions(-)

-- 
1.7.11.2
