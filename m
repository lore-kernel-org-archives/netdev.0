From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net 0/3] Few mvneta fixes
Date: Tue,  8 Mar 2016 13:57:03 +0100
Message-ID: <1457441826-6100-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Patrick Uiterwijk <patrick@puiterwijk.org>,
	Dimitri Epshtein <dima@marvell.com>,
	Ofer Heifetz <oferh@marvell.com>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

here is a patch set of few fixes. Without the first one, a kernel
configured with debug features ended to hang when the driver is built
as a module and is removed. This is quite is annoying for debugging!

The second patch fix a forgotten flag at the initial submission of the
driver.

The third patch is only really a cosmetic one so I have no problem to
not apply it for 4.5 and wait for 4.6.

I really would like to see the first one applied for 4.5 and for the
second I let you judge if it something needed for now or that should
wait the next release.

Thanks,

Gregory

Dmitri Epshtein (2):
  net: mvneta: enable change MAC address when interface is up
  net: mvneta: fix error messages in mvneta_port_down function

Gregory CLEMENT (1):
  net: mvneta: Fix spinlock usage

 drivers/net/ethernet/marvell/mvneta.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

-- 
2.5.0
