From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next 0/2] Add ptp vlan support
Date: Wed, 25 Jun 2014 14:25:46 +0200
Message-ID: <1403699148-10640-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: davem@davemloft.net, richardcochran@gmail.com, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cicero-fbr1.cybercity.dk ([212.242.40.5]:35650 "EHLO
	cicero4.cybercity.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638AbaFYNG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 09:06:59 -0400
Received: from cicero2.cybercity.dk (cicero2.cybercity.dk [212.242.40.53])
	by cicero4.cybercity.dk (Postfix) with ESMTP id 491C3DB5CB
	for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 14:28:38 +0200 (CEST)
Received: from HORWDSPRD01.spectralink.com (213083164185.static.sonofon.dk [213.83.164.185])
	by cicero2.cybercity.dk (Postfix) with ESMTP id 5BEC71088A6
	for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 14:27:48 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds functionality for running ptp/ieee1588 over vlan=
=2E

Stefan S=C3=B8rensen (2):
  ptp: Classify ptp over ip over vlan packets
  vlan: Pass SIOC[SG]HWTSTAMP ioctls to real device

 drivers/net/ethernet/ti/cpts.c | 24 ++++++++--------
 drivers/net/phy/dp83640.c      | 46 ++++++++++++++----------------
 include/linux/ptp_classify.h   |  5 ++--
 net/8021q/vlan_dev.c           |  2 ++
 net/core/ptp_classifier.c      | 64 ++++++++++++++++++++++++++++++++++=
++++----
 net/core/timestamping.c        | 57 +++++++++++++---------------------=
---
 6 files changed, 114 insertions(+), 84 deletions(-)

--=20
1.9.3
