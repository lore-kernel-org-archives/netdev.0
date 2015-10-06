From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/3] s390: qeth patches for net-next
Date: Tue,  6 Oct 2015 15:12:26 +0200
Message-ID: <1444137149-919-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:39238 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552AbbJFNMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 09:12:39 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Tue, 6 Oct 2015 14:12:38 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Hi Dave,

here are some s390 related patches for net-next. The qeth patches
are performance optimizations in the driver. The qdio patch corrects
a warning condition.

shortlog:

Thomas Richter(1):
  s390/qeth: switch to napi_gro_receive

Lakhvich Dmitriy (1):
  s390/qeth: optimize MAC handling in rx_mode callback

Eugene Crosser (1):
  s390/qdio: fix WARN_ON_ONCE condition

Thanks,
       Ursula
-- 
2.3.9
