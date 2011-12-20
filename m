From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH iproute2 0/3] netem iproute2 userspace parts
Date: Tue, 20 Dec 2011 22:28:45 +0100
Message-ID: <1324416528-3845-1-git-send-email-hagen@jauu.net>
Cc: shemminger@vyatta.com, Hagen Paul Pfeifer <hagen@jauu.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:42969 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752230Ab1LTV3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 16:29:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Stephen,

the follow serie provides support for netem rate extension. The s32 parser was
already discussed. I extend the man page to describe the extension.

Hagen

Hagen Paul Pfeifer (3):
  utils: add s32 parser
  tc: netem rate shaping and cell extension
  netem: extend man page for rate extension

 include/linux/pkt_sched.h |    8 +++++
 include/utils.h           |    1 +
 lib/utils.c               |   19 +++++++++++++
 man/man8/tc-netem.8       |   66 +++++++++++++++++++++++++++++++++++---------
 tc/q_netem.c              |   53 +++++++++++++++++++++++++++++++++++-
 5 files changed, 132 insertions(+), 15 deletions(-)

-- 
1.7.7.3
