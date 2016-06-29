From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: net.git commit 3bb549ae4c51
Date: Wed, 29 Jun 2016 15:18:55 -0400
Message-ID: <20160629191855.GA15982@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:16392 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbcF2TT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 15:19:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm getting ready with the next installment of changes to rds-tcp
for mprds, and I noticed that commit 3bb549ae4c51 ("RDS: TCP:
rds_tcp_accept_one() should transition socket from RESETTING to UP")
has not made its way to net-next.  I also noticed that (even though this
is a one-liner), this patch generates a conflict when applied as-is
to net-next.

My planned changes will cause more turbulence around this piece 
of code, so they depend on this patch. What is the advised approach
here? Should I just port this patch over to net-next as part
of my patch-set, and make a note about the port, or something else?

--Sowmini
