From: paul.moore@hp.com
Subject: [patch 0/1] NetLabel bugfix for 2.6.19
Date: Mon, 30 Oct 2006 13:03:31 -0500
Message-ID: <20061030180331.404950000@hp.com>
Cc: jmorris@redhat.com, sds@epoch.ncsc.mil, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:28088 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S932472AbWJ3SIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2006 13:08:06 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry, but another bugfix patch for NetLabel which I think should be included
2.6.19.

The problem is that the SELinux reference policy is a bit more free in allowing
applications to call setsockopt() than I had originally thought, which means
that normal applications could add or tamper with the NetLabel/CIPSO options on
a socket causing all sorts of nastiness.  This patch should solve these
problems.

--
paul moore
linux security @ hp
