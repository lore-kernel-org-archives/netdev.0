From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [2.6.19 PATCH 0/7] ehea: IBM eHEA Ethernet Device Driver
Date: Wed, 23 Aug 2006 10:55:49 +0200
Message-ID: <200608231055.49375.ossthema@de.ibm.com>
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
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:37205 "EHLO
	mtagate3.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1751482AbWHWJgF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 05:36:05 -0400
Content-Disposition: inline
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

in this latest version of the IBM eHEA Ethernet Device Driver
we removed all unnecessary variable initializations and did some
code cleanup. We hope that we didn't miss to respond to any of your
suggestions. Please feel free to send us further feedback. We highly
appreciate your efforts.

Thanks,
Jan-Bernd

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
Changelog-by: =A0Jan-Bernd Themann <themann@de.ibm.com>

Differences to patch set http://www.spinics.net/lists/netdev/msg12702.h=
tml

Changelog:

- Unnecessary variable initializations removed
- Promiscuous mode support included

 drivers/net/Kconfig             |    9=20
 drivers/net/Makefile            |    1=20
 drivers/net/ehea/Makefile       |    7=20
 drivers/net/ehea/ehea.h         |  438 ++++++
 drivers/net/ehea/ehea_ethtool.c |  244 +++
 drivers/net/ehea/ehea_hcall.h   |   51=20
 drivers/net/ehea/ehea_hw.h      |  290 ++++
 drivers/net/ehea/ehea_main.c    | 2677 +++++++++++++++++++++++++++++++=
+++++++++
 drivers/net/ehea/ehea_phyp.c    |  784 +++++++++++
 drivers/net/ehea/ehea_phyp.h    |  463 ++++++
 drivers/net/ehea/ehea_qmr.c     |  607 +++++++++
 drivers/net/ehea/ehea_qmr.h     |  361 +++++
 12 files changed, 5932 insertions(+)
