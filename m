From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 0/2] iproute2: add support for L2TP over IPv6, add manpage
Date: Fri, 20 Apr 2012 12:29:41 +0100
Message-ID: <1334921383-32109-1-git-send-email-jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:57093 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754999Ab2DTL3u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 07:29:50 -0400
Received: from localhost.localdomain (jchapman.plus.com [80.229.30.198])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: james)
	by mail.katalix.com (Postfix) with ESMTPSA id F3AC7A6206A
	for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 12:29:43 +0100 (BST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "ip l2tp" commands already support L2TP over IPv4. These patches
add support for L2TP over IPv6 and add a man page covering the command
set.

The patches depend on the L2TP IPv6 patch series already submitted for
review.

Chris Elston (1):
  iproute2: allow IPv6 addresses for l2tp local and remote parameters

James Chapman (1):
  iproute2: add ip-l2tp man page

 ip/ipl2tp.c        |   59 +++++++--
 man/man8/ip-l2tp.8 |  350 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ip.8      |    3 +-
 3 files changed, 397 insertions(+), 15 deletions(-)
 create mode 100644 man/man8/ip-l2tp.8
