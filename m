From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: net: Network driver for the Armada 370 and Armada XP ARM Marvell SoCs
Date: Tue,  4 Sep 2012 15:06:40 +0200
Message-ID: <1346764004-16332-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
 Ike Pan <ike.pan@canonical.com>, Albert Stone <albert.stone@canonical.com>,
 Nadav Haklai <nadavh@marvell.com>, Ian Molton <ian.molton@codethink.co.uk>,
 David Marlin <dmarlin@redhat.com>, Rami Rosen <rosenr@marvell.com>,
 Yehuda Yitschak <yehuday@marvell.com>,
 Jani Monoses <jani.monoses@canonical.com>, Tawfik Bayouk <tawfik@marvell.com>,
 Dan Frazier <dann.frazier@canonical.com>, Eran Ben-Avi <benavi@marvell.com>,
 Li Li <li.li@canonical.com>, Leif Lindholm <leif.lindholm@arm.com>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 Jason Cooper <jason@lakedaemon.net>, Arnd Bergmann <arnd@arndb.de>,
 Jon Masters <jcm@redhat.com>, Ben Dooks <ben-linux@fluff.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
To: "David S. Miller" <davem@davemloft.net>,
 Lennert Buytenhek <kernel@wantstofly.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

David, Lennert,

This patch set adds a new network driver for the network unit
available in the newest Marvell ARM SoCs Armada 370 and Armada XP, as
well as the necessary Device Tree information to use this driver in
the two evaluation platforms of those SoCs.

In details:

 * Patch 1 contains the driver itself. The commit log contains a
   detailed explanation about why a new driver is needed for this new
   Marvell SoC, compared to older Marvell SoCs (Orion, Kirkwood, Dove)
   that use the mv643xx_eth driver.

 * Patch 2 adds the necessary entry to the MAINTAINERS file.

 * Patch 3 adds the SoC-level Device Tree information for Armada 370
   and Armada XP.

 * Patch 4 adds the board-level Device Tree information for the
   Marvell evaluation boards of Armada 370 and Armada XP.

Thanks,

Thomas Petazzoni
