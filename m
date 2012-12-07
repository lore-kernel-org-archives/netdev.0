From: Jan Synacek <jsynacek@redhat.com>
Subject: [PATCH 0/2] iputils: minor ninfod and ping6 fixes
Date: Fri,  7 Dec 2012 09:25:22 +0100
Message-ID: <1354868724-15549-1-git-send-email-jsynacek@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Jan Synacek <jsynacek@redhat.com>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13274 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753926Ab2LGIZm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2012 03:25:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

When calling ping6 with the flowlabel (e.g. `ping6 -F 123 ::1'), it exited with
an error. For some reason, the errno was set when it should not have been. Maybe
it shouldn't be checked at all, maybe just checking flowlabel for values below
zero would be enough. I wanted to be on the safer side so I left the errno check
in there.

Also, I fixed the rest of the unused variables in ninfod.

Jan Synacek (2):
  ninfod: Fix more unused variables.
  ping6: Fix -F switch.

 ninfod/ni_ifaddrs.c | 8 +-------
 ping6.c             | 3 ++-
 2 files changed, 3 insertions(+), 8 deletions(-)

-- 
1.8.0.1
