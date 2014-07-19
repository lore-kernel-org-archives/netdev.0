From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Measurable performance improvements from RCU_INIT_POINTER()?
Date: Sat, 19 Jul 2014 01:12:40 -0700
Message-ID: <20140719081240.GA13806@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: edumazet@google.com, davem@davemloft.net, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:47571 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754118AbaGSRmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2014 13:42:43 -0400
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Sat, 19 Jul 2014 11:42:43 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 873341FF003B
	for <netdev@vger.kernel.org>; Sat, 19 Jul 2014 11:42:39 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07029.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6JFcx982883974
	for <netdev@vger.kernel.org>; Sat, 19 Jul 2014 17:38:59 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s6JHklwo015547
	for <netdev@vger.kernel.org>; Sat, 19 Jul 2014 11:46:47 -0600
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

Did the replacement of selected calls to rcu_assign_pointer() by
RCU_INIT_POINTER() in the networking stack result in measurable
system-level performance improvements?

The reason I ask is that some of the compiler guys on the C and C++
standards committees are suggesting changes that would add barriers
in some cases.  I suspect that this is a very bad idea, and was hoping
that you guys would have some hard numbers on the system-level effects
of barriers.  ;-)

							Thanx, Paul
