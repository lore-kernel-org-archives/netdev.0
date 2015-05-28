From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net 0/3] bna: misc bugfixes
Date: Thu, 28 May 2015 23:10:05 +0200
Message-ID: <1432847408-5066-1-git-send-email-ivecera@redhat.com>
Cc: Rasesh Mody <rasesh.mody@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39874 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751812AbbE1VKE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 17:10:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches fix several bugs found during device initialization debugging.

Cc: Rasesh Mody <rasesh.mody@qlogic.com>

Ivan Vecera (3):
  bna: fix firmware loading on big-endian machines
  bna: remove unreasonable iocpf timer start
  bna: fix soft lock-up during firmware initialization failure

 drivers/net/ethernet/brocade/bna/bfa_ioc.c   | 4 ++--
 drivers/net/ethernet/brocade/bna/bnad.c      | 4 ----
 drivers/net/ethernet/brocade/bna/cna_fwimg.c | 7 +++++++
 3 files changed, 9 insertions(+), 6 deletions(-)

-- 
2.3.6
