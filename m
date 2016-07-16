From: Richard Stearn <richard@rns-stearn.demon.co.uk>
Subject: [PATCH 0/6]NET:AX25:ROSE Adds device use count, adds trap to
 prevent kernel crash, plus other cleanup
Date: Sat, 16 Jul 2016 10:40:59 +0100
Message-ID: <201607160940.u6G9exbE014395@ux4.g1sog>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mdfmta005.mxout.tbr.inty.net ([91.221.168.46]:42839 "EHLO
	smtp.demon.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751351AbcGPJrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2016 05:47:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 0/6]NET:AX25:ROSE Adds device use count, adds trap to prevent kernel crash, plus other cleanup
[PATCH 1/6]NET:AX25:ROSE
Adds device use count for core of protocol.

[PATCH 2/6]NET:AX25:ROSE
Adds device use counting for ROSE neighbour lists

[PATCH 3/6]NET:AX25:ROSE
Traps calls to rose_route_frame with a NULL ax25 callback. Prevents a kernel crash.

[PATCH 4/6]NET:AX25:ROSE
Adds comments on the header fields. Removes address copy.

[PATCH 5/6]NET:AX25:ROSE
Adds the log priority to a printk.

[PATCH 6/6]NET:AX25:ROSE
Removes a conditional return and corrects the return value.

 net/rose/af_rose.c       |    7 ++++++-
 net/rose/rose_dev.c      |   18 ++++++------------
 net/rose/rose_loopback.c |    1 +
 net/rose/rose_route.c    |   22 ++++++++++++++++++----
 5 files changed, 33 insertions(+), 19 deletions(-)
