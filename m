From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next V2 0/5] s390: qeth and iucv patches
Date: Fri, 18 Sep 2015 16:06:47 +0200
Message-ID: <1442585212-58347-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp05.uk.ibm.com ([195.75.94.101]:50543 "EHLO
	e06smtp05.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752678AbbIROHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 10:07:04 -0400
Received: from /spool/local
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 18 Sep 2015 15:07:02 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Hi Dave,

here is version 2 of some s390 related qeth patches for net-next. The patch by
Thomas Richter adds a new feature to the qeth layer2 code; the remaining
patches are minor improvements.
Version 2 of patch 4 uses the desired indentation in function declarations
and definitions spanning multiple lines in almost all cases. Thomas run into a
conflict with the maximum number of columns once. Thus you will still see one
function definition using an earlier column before the opening paranthesis.

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
