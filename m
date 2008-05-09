From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH next-2.6] [SCTP] New SCTP functionality
Date: Fri,  9 May 2008 15:14:41 -0400
Message-ID: <1210360481-16599-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:19229 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755856AbYEITOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 15:14:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The following is a short summary of the new SCTP functionality

* Update implementation of SCTP_DELAYD_ACK to conform to the latest
  spec.  We now implement SACK frequency in the number of packets as well
  as time.

* Support the new sctp_connectx() functionality that returns the
  established association id.

* Implement the remote address table OID for the SCTP MIB.

-vlad
