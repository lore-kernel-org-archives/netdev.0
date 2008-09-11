From: Sebastien Dugue <sebastien.dugue@bull.net>
Subject: [PATCH 0/2] powerpc - EHEA fixes
Date: Thu, 11 Sep 2008 15:34:38 +0200
Message-ID: <1221140080-9853-1-git-send-email-sebastien.dugue@bull.net>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	themann@de.ibm.com, tklein@de.ibm.com, raisch@de.ibm.com,
	jeff@garzik.org, jean-pierre.dion@bull.net,
	gilles.carry@ext.bull.net, tinytim@us.ibm.com,
	sebastien.dugue@bull.net
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:37157 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813AbYIKNev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 09:34:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  Hi,

  here are 2 fixes for the ehea driver (nothing urgent here):

  - fix a typo which prevents building when DEBUG is #defined
  - fix mutex and spinlock usage in ehea_main

  and the diffstat for the patchset:

 drivers/net/ehea/ehea_main.c |   26 ++++----------------------
 drivers/net/ehea/ehea_phyp.c |    2 +-
 2 files changed, 5 insertions(+), 23 deletions(-)

  Thanks,

  Sebastien.

