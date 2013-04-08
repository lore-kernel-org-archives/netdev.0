From: frank.blaschka@de.ibm.com
Subject: [patch 0/2] s390: network bug fixes for net [v2]
Date: Mon, 08 Apr 2013 10:19:25 +0200
Message-ID: <20130408081925.995757091@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:37085 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934849Ab3DHIUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 04:20:09 -0400
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 8 Apr 2013 09:16:50 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are the fixes for net again, including
feedback from Eric (Thx!)

shortlog:

Ursula Braun (1)
af_iucv: fix recvmsg by replacing skb_pull() function

Stefan Raspl (1)
qeth: fix qeth_wait_for_threads() deadlock for OSN devices

Thanks,
        Frank
