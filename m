From: Krishna Kumar <kumarkr@linux.vnet.ibm.com>
Subject: [PATCH 0/2] qdisc_restart - readability changes, one bug fix plus
	couple of optimizations.
Date: Wed, 13 Jun 2007 14:10:43 +0530
Message-ID: <1181724044.10679.29.camel@localhost.localdomain>
Reply-To: kumarkr@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jamal@cyberus.ca, herbert@gondor.apana.org.au,
	peter.p.waskiewicz.jr@intel.com, tgraf@suug.ch, kaber@trash.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:41660 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754820AbXFMIkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 04:40:46 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l5D91lSN185212
	for <netdev@vger.kernel.org>; Wed, 13 Jun 2007 19:01:48 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5D8hjjr035150
	for <netdev@vger.kernel.org>; Wed, 13 Jun 2007 18:43:50 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5D8eBfk021827
	for <netdev@vger.kernel.org>; Wed, 13 Jun 2007 18:40:12 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

I am splitting this patch to two, to differentiate between readability
changes (plus a bug fix) and optimization changes.

Please review.

Thanks,

- KK

----------------------------------------------------------------------

I am sorry to miss out during Jamal's original effort to make qdisc_restart
more readable, but I feel some more minor changes could help in that effort.
Plus there were some useful comments in the original code which I updated
(hopefully correctly) and put back - it does seem useful for a new reader.

Ran a 50 process netperf4 TCP & UDP on 2 cpu SMP system without issues.

Please provide your comments/feedback (cc'ing the original reviewers also,
as per Jamal's mail from May 25th).

Thanks,

- KK


