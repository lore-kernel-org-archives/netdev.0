From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [2.6.19 PATCH 0/7] ehea: IBM eHEA Ethernet Device Driver
Date: Tue, 22 Aug 2006 14:50:03 +0200
Message-ID: <200608221450.03344.ossthema@de.ibm.com>
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
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:23158 "EHLO
	mtagate1.uk.ibm.com") by vger.kernel.org with ESMTP id S932218AbWHVNaL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 09:30:11 -0400
Content-Disposition: inline
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this is our current version of the IBM eHEA Ethernet Device Driver.
Thanks for the quick and helpful comments so far. Further comments
are highly appreciated.

Things we are currently working on:
- Implementation of promiscious mode support


Thanks,
Jan-Bernd

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
Changelog-by: =A0Jan-Bernd Themann <themann@de.ibm.com>

Differences to patch set http://www.spinics.net/lists/netdev/msg12326.h=
tml

Changelog:

- Error recovery
- improvements according to mailing list comments


 drivers/net/Kconfig             |    9=20
 drivers/net/Makefile            |    1=20
 drivers/net/ehea/Makefile       |    7=20
 drivers/net/ehea/ehea.h         |  437 ++++++
 drivers/net/ehea/ehea_ethtool.c |  244 +++
 drivers/net/ehea/ehea_hcall.h   |   51=20
 drivers/net/ehea/ehea_hw.h      |  290 ++++
 drivers/net/ehea/ehea_main.c    | 2636 +++++++++++++++++++++++++++++++=
+++++++++
 drivers/net/ehea/ehea_phyp.c    |  834 ++++++++++++
 drivers/net/ehea/ehea_phyp.h    |  479 +++++++
 drivers/net/ehea/ehea_qmr.c     |  634 +++++++++
 drivers/net/ehea/ehea_qmr.h     |  367 +++++
 12 files changed, 5989 insertions(+)
