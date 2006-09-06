From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [2.6.19 PATCH 0/7] ehea: IBM eHEA Ethernet Device Driver
Date: Wed, 6 Sep 2006 15:29:05 +0200
Message-ID: <200609061529.05632.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:37573 "EHLO
	mtagate4.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1751095AbWIFOLb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 10:11:31 -0400
Content-Disposition: inline
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this is the latest version of the IBM eHEA Ethernet Device Driver.
We integrated the comment we got from Francois Romieu.

Thanks,
Jan-Bernd

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>=20
Changelog-by: =A0Jan-Bernd Themann <themann@de.ibm.com>

Differences to patch set http://www.spinics.net/lists/netdev/msg13972.h=
tml

Changelog:
- replace dev_alloc_skb by netdev_alloc_skb
- goto target naming rework
- minor coding style issues


 drivers/net/Kconfig             |    9=20
 drivers/net/Makefile            |    1=20
 drivers/net/ehea/Makefile       |    6=20
 drivers/net/ehea/ehea.h         |  443 ++++++
 drivers/net/ehea/ehea_ethtool.c |  294 ++++
 drivers/net/ehea/ehea_hcall.h   |   51=20
 drivers/net/ehea/ehea_hw.h      |  290 ++++
 drivers/net/ehea/ehea_main.c    | 2686 +++++++++++++++++++++++++++++++=
+++++++++
 drivers/net/ehea/ehea_phyp.c    |  705 ++++++++++
 drivers/net/ehea/ehea_phyp.h    |  454 ++++++
 drivers/net/ehea/ehea_qmr.c     |  604 ++++++++
 drivers/net/ehea/ehea_qmr.h     |  362 +++++
 12 files changed, 5905 insertions(+)

