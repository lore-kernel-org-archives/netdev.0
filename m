From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [GIT PULL] SCTP bug fixes for net-2.6
Date: Thu, 29 Nov 2007 10:45:41 -0500
Message-ID: <1196351141-24722-1-git-send-email-vladislav.yasevich@hp.com>
Cc: herbert@gondor.apana.org.au,
	lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:8344 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760474AbXK2Pyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 10:54:37 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Herbert

The following changes since commit a357dde9df33f28611e6a3d4f88265e39bcc8880:
  Stephen Hemminger (1):
        [TCP] illinois: Incorrect beta usage

are available in the git repository at:

  aster.kernel.org:/pub/scm/linux/kernel/git/vxy/lksctp-dev.git pending

Vlad Yasevich (5):
      SCTP: Fix the number of HB transmissions.
      SCTP: Fix SCTP-AUTH to correctly add HMACS paramter.
      SCTP: Fix the supported extensions paramter
      SCTP: Fix chunk acceptance when no authenticated chunks were listed.
      SCTP: Fix build issues with SCTP AUTH.

 include/net/sctp/constants.h |    9 ++++++---
 net/sctp/Kconfig             |    6 +++---
 net/sctp/auth.c              |    4 +++-
 net/sctp/sm_make_chunk.c     |   25 +++++++++----------------
 net/sctp/sm_statefuns.c      |    2 +-
 5 files changed, 22 insertions(+), 24 deletions(-)

Thanks
-vlad
