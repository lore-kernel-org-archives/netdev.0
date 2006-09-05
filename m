From: Andrew Morton <akpm@osdl.org>
Subject: Fw: AIM7 fails with 2.6.18-rc5-mm1
Date: Tue, 5 Sep 2006 00:08:50 -0700
Message-ID: <20060905000850.8adebdad.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:36817 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965191AbWIEHIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2006 03:08:53 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We think this is a net bug.


Begin forwarded message:

Date: Mon, 4 Sep 2006 17:02:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
To: davem@davemloft.net
Cc: linux-kernel@vger.kernel.org
Subject: AIM7 fails with 2.6.18-rc5-mm1


On an 8p Altix. 6 GB Ram

AIM Multiuser Benchmark - Suite VII Run Beginning

Tasks    jobs/min  jti  jobs/min/task      real       cpu
    1     2435.06  100      2435.0649      2.46      0.02   Mon Sep  4 
10:17:44 2006
  100   178784.27   94      1787.8427      3.36      7.08   Mon Sep  4 
10:17:58 2006
  200   280636.11   95      1403.1805      4.28     14.46   Mon Sep  4 
10:18:15 2006
  300   340973.67   91      1136.5789      5.28     22.35   Mon Sep  4 
10:18:37 2006
  400   382897.26   82       957.2431      6.27     30.44   Mon Sep  4 
10:19:03 2006
  500   413793.10   86       827.5862      7.25     38.14   Mon Sep  4 
10:19:33 2006
  600   434940.20   89       724.9003      8.28     46.43   Mon Sep  4 
10:20:07 2006
  700
Fatal error 98 at line 284 of file pipe_test.c: bind on write -- Address 
already in use

Child #489: : Address already in use

Failed to execute
        udp_test 100

Fatal error 98 at line 264 of file pipe_test.c: bind on write -- Address 
already in use

Child #286: : Address already in use

Failed to execute
        udp_test 100

etc etc

Is this a known issue?

-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
