From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/5] SCTP update
Date: Wed, 11 Jun 2014 16:34:52 +0200
Message-ID: <1402497297-27100-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61064 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751965AbaFKOfB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 10:35:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set contains transport path selection improvements in
SCTP. Please see individual patches for details.

Thanks!

Daniel Borkmann (5):
  ktime: add ktime_after and ktime_before helper
  net: sctp: refactor active path selection
  net: sctp: migrate most recently used transport to ktime
  net: sctp: improve sctp_select_active_and_retran_path selection
  net: sctp: fix incorrect type in gfp initializer

 include/linux/ktime.h      |  24 +++++++
 include/net/sctp/structs.h |   6 +-
 net/sctp/associola.c       | 168 ++++++++++++++++++++++++++++-----------------
 net/sctp/endpointola.c     |   2 +-
 net/sctp/sm_make_chunk.c   |   2 +-
 net/sctp/transport.c       |   2 +-
 6 files changed, 136 insertions(+), 68 deletions(-)

-- 
1.7.11.7
