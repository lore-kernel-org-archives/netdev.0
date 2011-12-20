From: frank.blaschka@de.ibm.com
Subject: [patch 00/10] s390: network driver features and fixes for net-next
Date: Tue, 20 Dec 2011 09:56:26 +0100
Message-ID: <20111220085626.924756639@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:33440 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230Ab1LTI5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 03:57:41 -0500
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 20 Dec 2011 08:57:39 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some s390 network driver features and fixes for net-next

shortlog:

Ursula Braun (8)
af_iucv: support ancillary data with HS transport
af_iucv: accelerate close for HS transport
af_iucv: release reference to HS device
af_iucv: remove unused timer infrastructure
af_iucv: get rid of state IUCV_SEVERED
qeth: suspicious rcu_dereference_check in recovery
qeth: forbid recovery during shutdown
netiucv: allow multiple interfaces to same peer

Frank Blaschka (1)
qeth: improve recovery during resource shortage

Einar Lueck (1)
qeth: recovery through asynchronous delivery

Thanks,
        Frank
