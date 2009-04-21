From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 00/13] iucv / af_iucv patches for 2.6.30-rc1
Date: Tue, 21 Apr 2009 12:34:57 +0200
Message-ID: <20090421103457.965299000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:45202 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707AbZDUKhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 06:37:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

here is the series of iucv / af_iucv patches for the current
development cycle.
The patches are based on top of the current net-2.6 kernel
(2.6.30-rc1).

Hendrik Brueckner (11):
    af_iucv: fix oops in iucv_sock_recvmsg() for MSG_PEEK flag
    af_iucv: Reject incoming msgs if RECV_SHUTDOWN is set
    af_iucv: sync sk shutdown flag if iucv path is quiesced
    af_iucv: Test additional sk states in iucv_sock_shutdown
    af_iucv: add sockopt() to enable/disable use of IPRM_DATA msgs
    af_iucv: Support data in IUCV msg parameter lists (IPRMDATA)
    af_iucv: Modify iucv msg target class using control msghdr
    af_iucv: Provide new socket type SOCK_SEQPACKET
    af_iucv: cleanup and refactor recvmsg() EFAULT handling
    af_iucv: New socket option for setting IUCV MSGLIMITs
    af_iucv: Fix race when queuing incoming iucv messages

Ursula Braun (2):
    iucv: provide second per-cpu IUCV command parameter block
    af_iucv: consider state IUCV_CLOSING when closing a socket

Kind regards,
Ursula Braun

