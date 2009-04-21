From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 0/5] [RESEND] af_iucv patches for 2.6.30-rc1
Date: Tue, 21 Apr 2009 18:04:19 +0200
Message-ID: <20090421160419.971500000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:35976 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662AbZDUQPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 12:15:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

as suggested, here is the series of critical af_iucv bug fixes.
I will submit the remaining af_iucv patches to net-next-2.6.
The patches are based on top of the current net-2.6 kernel
(2.6.30-rc1).

Hendrik Brueckner (11):
    af_iucv: fix oops in iucv_sock_recvmsg() for MSG_PEEK flag
    af_iucv: Reject incoming msgs if RECV_SHUTDOWN is set
    af_iucv: Test additional sk states in iucv_sock_shutdown
    af_iucv: Fix race when queuing incoming iucv messages

Ursula Braun (2):
    af_iucv: consider state IUCV_CLOSING when closing a socket

Kind regards,
Ursula Braun

