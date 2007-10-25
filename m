From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH] NetLabel fixes against 2.6.24-rc1
Date: Thu, 25 Oct 2007 09:52:32 -0400
Message-ID: <20071025134727.6382.79273.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:33047 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754669AbXJYNwh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 09:52:37 -0400
Received: from smtp1.fc.hp.com (smtp.cnd.hp.com [15.15.136.127])
	by atlrel7.hp.com (Postfix) with ESMTP id AE862364D6
	for <netdev@vger.kernel.org>; Thu, 25 Oct 2007 09:52:36 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There have been some good discussions on the list about RCU lately that made
me realize NetLabel was doing some rather stupid things in regards to how it
makes use of RCU.  This is a small patch again against 2.6.24-rc1 which should
fix the RCU problems.  You can grab the patch from email or from here:

 * git://git.infradead.org/users/pcmoore/lblnet-2.6

I tested last patch last week using some stress tests for a few days and
didn't nothing anything out of the oridinary.  Please consider for 2.6.24.

Thanks.

-- 
paul moore
linux security @ hp

