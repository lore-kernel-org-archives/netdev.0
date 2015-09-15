From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/5] s390: qeth and iucv patches
Date: Tue, 15 Sep 2015 12:32:13 +0200
Message-ID: <1442313138-64526-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:45903 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644AbbIOKc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 06:32:27 -0400
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Tue, 15 Sep 2015 11:32:24 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Hi Dave,

here are some s390 related qeth patches for net-next. The patch by
Thomas Richter adds a new feature to the qeth layer2 code; the remaining
patches are minor improvements.

shortlog:

Eugene Crosser (1):
  qeth: remove extraneous length from %pM format

Lakhvich Dmitriy (1):
  qeth: no write permission for readonly sysattr

Thomas Richter(1):
  qeth: add layer 2 RX/TX checksum offloading

Ursula Braun(2):
  qeth: move OSA portname into deprecated status
  s390/iucv: do not use arrays as argument

Thanks,
       Ursula
-- 
2.3.8
