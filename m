From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: latest linux git doesn't compile ucc_geth_phy.c and ucc_geth.c
Date: Wed, 13 Dec 2006 13:44:47 +0100
Message-ID: <1166013887.30422.54.camel@gentoo-jocke.transmode.se>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev <linuxppc-dev@ozlabs.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: netdev@vger.kernel.org
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

drivers/net/ucc_geth.c:4083:45: macro "INIT_WORK" passed 3 arguments,
but takes just 2
drivers/net/ucc_geth.c: In function `ucc_geth_open':
drivers/net/ucc_geth.c:4083: error: `INIT_WORK' undeclared (first use in
this function)
drivers/net/ucc_geth.c:4083: error: (Each undeclared identifier is
reported only once
drivers/net/ucc_geth.c:4083: error: for each function it appears in.)
drivers/net/ucc_geth.c: At top level:
drivers/net/ucc_geth.c:3924: warning: 'ugeth_phy_change' defined but not
used
make[2]: *** [drivers/net/ucc_geth.o] Error 1

drivers/net/ucc_geth_phy.c:71: error: conflicting types for 'phy_read'
include/linux/phy.h:355: error: previous declaration of 'phy_read' was
here
drivers/net/ucc_geth_phy.c:71: error: conflicting types for 'phy_read'
include/linux/phy.h:355: error: previous declaration of 'phy_read' was
here
drivers/net/ucc_geth_phy.c:72: error: conflicting types for 'phy_write'
include/linux/phy.h:356: error: previous declaration of 'phy_write' was
here
drivers/net/ucc_geth_phy.c:72: error: conflicting types for 'phy_write'
include/linux/phy.h:356: error: previous declaration of 'phy_write' was
here
