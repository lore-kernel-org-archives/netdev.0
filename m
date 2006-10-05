From: paul.moore@hp.com
Subject: [PATCH 0/1] NetLabel changes from yesterday's discussion
Date: Thu, 05 Oct 2006 18:28:23 -0400
Message-ID: <20061005222823.387569000@hp.com>
Cc: jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:23209 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S932396AbWJEWhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 18:37:05 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case you missed it (har har) there was a pretty good discussion about
labeled networking yesterday.  One of the results of the dicussion was the
realization that the way NetLabel determines what to use for the SELinux TE
portion of the packet's label was not the best choice.  This patch should
address the issue.

This patch does not rely on the secid patches currently in progress and should
be considered a bugfix against the current net-2.6 tree.

--
paul moore
linux security @ hp
