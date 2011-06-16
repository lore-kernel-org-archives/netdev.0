From: Bernard Metzler <BMT@zurich.ibm.com>
Subject: Software iWARP Stack  - take 2
Date: Thu, 16 Jun 2011 14:40:15 +0200
Message-ID: <OF1C33406E.B63E358D-ONC12578B1.0042DB9D-C12578B1.00459AEE@ch.ibm.com>
References: <BANLkTimEGgKEMZd3qppOofN-Vj-u-PH-xA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Bart Van Assche <bvanassche@acm.org>,
	Roland Dreier <roland@kernel.org>
To: linux-rdma-owner@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([194.196.100.167]:37379 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864Ab1FPMkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 08:40:16 -0400
In-Reply-To: <BANLkTimEGgKEMZd3qppOofN-Vj-u-PH-xA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bart, Roland, all,

many thanks for the suggestions and input. I am happy
to see interest in SoftiWARP.

In the hope to contribute something usefull, I will now
send a complete new set of patches against net-next.
It adds software iWARP support on top of TCP kernel sockets
and fits into the linux-rdma kernel stack.

Major changes to the previous (first) posting from October last
year include some kernel client support, restructuring of the
connection management code and general code cleanup.
I hope all issues which were rised after the first posting are
resolved. Thanks again for the valuable feedback.

Please take the current code contribution as work in progress.
Any comment and input is highly appreciated.


Here comes a shortlog of what you should expect:

Bernard Metzler (14):
      SIWv2: Kconfig and Makefile
      SIWv2: iWARP Protocol headers: iwarp.h
      SIWv2: Main header file: siw.h
      SIWv2: Module initialization: siw_main.c
      SIWv2: User interface: siw_verbs.h, siw_verbs.c, siw_user.h, siw_ae.c
      SIWv2: Connection management: siw_cm.c, siw_cm.h
      SIWv2: Object management: siw_obj.c, siw_obj.h
      SIWv2: Queue pair: siw_qp.c
      SIWv2: Completion queue: siw_cq.c
      SIWv2: Transmit path: siw_qp_tx.c
      SIWv2: Receive path: siw_qp_rx.c
      SIWv2: Debugging and Tracing: siw_debug.c, siw_debug.h
      SIWv2: Memory management: siw_mem.c
      SIWv2: Documentation: siw.txt



Many thanks,
Bernard.

