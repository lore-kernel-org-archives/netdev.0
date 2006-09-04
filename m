From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [2.6.19 PATCH 0/7] ehea: IBM eHEA Ethernet Device Driver
Date: Mon, 4 Sep 2006 12:36:32 +0200
Message-ID: <200609041236.32279.ossthema@de.ibm.com>
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
Received: from mtagate4.de.ibm.com ([195.212.29.153]:21034 "EHLO
	mtagate4.de.ibm.com") by vger.kernel.org with ESMTP
	id S1750797AbWIDLSi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 07:18:38 -0400
Content-Disposition: inline
To: netdev <netdev@vger.kernel.org>, Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this is our current version of the IBM eHEA Ethernet Device Driver. We =
added=20
minor bug fixes and changes to the last version.

Jeff, this driver has been discussed on the netdev, linux-ppc and=20
kernel mailing list. We didn't receive any further comments since our p=
revious
patch set from August 23. Please consider our driver for
upstream inclusion.

Thanks,

Jan-Bernd Themann & Christoph Raisch

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
Changelog-by: =A0Jan-Bernd Themann <themann@de.ibm.com>

Differences to patch set http://www.spinics.net/lists/netdev/msg12820.h=
tml

Changelog:
- struct ehea_q_skb_arr introduced to simplify struct ehea_port_res
- promiscuous mode added
- enhanced ethtool support (set port speed)
- destroy functions for QPs, CQs, EQs, MRs reduced to single function
- Bux fix: xmit locking


 drivers/net/Kconfig             |    9=20
 drivers/net/Makefile            |    1=20
 drivers/net/ehea/Makefile       |    6=20
 drivers/net/ehea/ehea.h         |  444 ++++++
 drivers/net/ehea/ehea_ethtool.c |  292 ++++
 drivers/net/ehea/ehea_hcall.h   |   51=20
 drivers/net/ehea/ehea_hw.h      |  290 ++++
 drivers/net/ehea/ehea_main.c    | 2694 +++++++++++++++++++++++++++++++=
+++++++++
 drivers/net/ehea/ehea_phyp.c    |  705 ++++++++++
 drivers/net/ehea/ehea_phyp.h    |  454 ++++++
 drivers/net/ehea/ehea_qmr.c     |  605 ++++++++
 drivers/net/ehea/ehea_qmr.h     |  361 +++++
 12 files changed, 5912 insertions(+)

--=20
VGER BF report: U 0.490082
