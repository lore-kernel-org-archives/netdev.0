From: "Paul Moore" <paul.moore@hp.com>
Subject: [PATCH 0/2] Two pretty trivial NetLabel bugfixes
Date: Fri, 05 Jan 2007 15:08:20 -0500
Message-ID: <20070105200820.975960210@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:35045 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750710AbXAEUQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jan 2007 15:16:46 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a small patchset both in the number of patches (two) and the size of
the patches themselves.  The first patch fixes a potential locking issue with
a NetLabel state variable and the second patch fixes a couple of problems seen
when adding new CIPSO DOI definitions.

In light of the recent NetLabel locking issues I've spent this week going over
all of the NetLabel related locks and I firmly believe this patchset should
address the last of the problems.  However, if anyone with a good knowledge of
socket/sk locking can afford to take a look I would greatly appreciate it.

I tested both of these patches with what I believe to be pretty much all of
the kernel debug options enabled and I have not encountered any problems.
Please consider these for the 2.6.20 release.

--
paul moore
linux security @ hp
