From: "Paul Moore" <paul.moore@hp.com>
Subject: [PATCH 0/2] Small memory-leak patchset
Date: Wed, 01 Aug 2007 11:12:57 -0400
Message-ID: <20070801151257.475951538@hp.com>
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:42001 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757593AbXHAPZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2007 11:25:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While doing some other work I found some small memory leaks with the way
we are using security_secid_to_secctx() in some of the auditing code paths.
We also had a redundant NULL pointer check in the SELinux function which frees
the leaked memory.  This patchset fixes both of these issues.

This patchset is backed against Linus' tree from this morning and has been
lightly tested.

-- 
paul moore
linux security @ hp
