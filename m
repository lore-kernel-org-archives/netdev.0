From: Jan Synacek <jsynacek@redhat.com>
Subject: [PATCH 0/2] iputils: ninfod minor changes
Date: Wed, 23 Jan 2013 14:37:43 +0100
Message-ID: <1358948265-20867-1-git-send-email-jsynacek@redhat.com>
Cc: netdev@vger.kernel.org, Jan Synacek <jsynacek@redhat.com>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56679 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754530Ab3AWNhw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 08:37:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Functions limiting capabilities as well as opening a socket could have been
called needlessly if ninfod was invoked with -h.

Also, ninfod incorrectly kept running if invoked with -v.

Jan Synacek (2):
  ninfod: Call limit/drop_capabilities() and open_sock() after checking
    for -h or -v.
  ninfod: Make -v exit correctly.

 ninfod/ninfod.c | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

-- 
1.8.1
