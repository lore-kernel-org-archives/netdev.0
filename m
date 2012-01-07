From: Shawn Guo <shawn.guo@linaro.org>
Subject: linux-next: net/smsc911x compile error on next-20120106
Date: Sat, 7 Jan 2012 13:55:41 +0800
Message-ID: <CAAQ0ZWSRzUM2rdhfWDqang6Baat6x-gEso5hQGEkbOqFjM-sMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: Stephen Rothwell <sfr@canb.auug.org.au>, David Miller <davem@davemloft.net>
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

Hi Stephen, David,

I just ran into the following compile error when building
next-20120106 with imx_v6_v7_defconfig.

  CC      drivers/net/ethernet/smsc/smsc911x.o
drivers/net/ethernet/smsc/smsc911x.c: In function
=91smsc911x_phy_disable_energy_detect=92:
drivers/net/ethernet/smsc/smsc911x.c:1329:32: error:
=91MII_LAN83C185_CTRL_STATUS=92 undeclared (first use in this function)
drivers/net/ethernet/smsc/smsc911x.c:1329:32: note: each undeclared
identifier is reported only once for each function it appears in
drivers/net/ethernet/smsc/smsc911x.c:1340:12: error:
=91MII_LAN83C185_EDPWRDOWN=92 undeclared (first use in this function)
drivers/net/ethernet/smsc/smsc911x.c:1341:13: error:
=91MII_LAN83C185_ENERGYON=92 undeclared (first use in this function)
drivers/net/ethernet/smsc/smsc911x.c: In function
=91smsc911x_phy_enable_energy_detect=92:
drivers/net/ethernet/smsc/smsc911x.c:1364:32: error:
=91MII_LAN83C185_CTRL_STATUS=92 undeclared (first use in this function)
drivers/net/ethernet/smsc/smsc911x.c:1372:13: error:
=91MII_LAN83C185_EDPWRDOWN=92 undeclared (first use in this function)

-- =

Regards,
Shawn
