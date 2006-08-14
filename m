From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 0/7] ehea: IBM eHEA Ethernet Device Driver
Date: Mon, 14 Aug 2006 18:28:30 +0200
Message-ID: <44E0A4AE.3080600@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Klein <tklein@de.ibm.com>, Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Thomas Klein <osstklei@de.ibm.com>, linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>, Marcus Eder <meder@de.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: netdev <netdev@vger.kernel.org>
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

Hi,

this is the latest version of the IBM eHEA Ethernet Device Driver.
We got a lot of very helpful comments and modified our driver as we
said in our replies.

Thanks for your efforts so far!

Things we are still working on:
- Debug output rework (EDEB, remove unimportant debug information,
   using standard kernel mechanisms where possible)
- performance improvements on SMP systems
- error recovery

Thanks,
Jan-Bernd

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
Changelog-by:  Jan-Bernd Themann <themann@de.ibm.com>

Differences to patch set http://www.spinics.net/lists/netdev/msg10997.html

Changelog:

- Proper use of alloc_etherdev() / netdev_priv()
- Several memory leeks fixed
- Split big functions
- 64K page support
- Code cleanup (removed unnecessary casts, unused defines,
   ethtool stub functions removed, renaming prefixes, comments, ...)


  drivers/net/Kconfig             |    6
  drivers/net/Makefile            |    1
  drivers/net/ehea/Makefile       |    7
  drivers/net/ehea/ehea.h         |  470 +++++++
  drivers/net/ehea/ehea_ethtool.c |  271 ++++
  drivers/net/ehea/ehea_hcall.h   |   52
  drivers/net/ehea/ehea_hw.h      |  315 ++++
  drivers/net/ehea/ehea_main.c    | 2672 ++++++++++++++++++++++++++++++++++++++++
  drivers/net/ehea/ehea_phyp.c    | 1087 ++++++++++++++++
  drivers/net/ehea/ehea_phyp.h    |  562 ++++++++
  drivers/net/ehea/ehea_qmr.c     |  757 +++++++++++
  drivers/net/ehea/ehea_qmr.h     |  392 +++++
  12 files changed, 6592 insertions(+)
