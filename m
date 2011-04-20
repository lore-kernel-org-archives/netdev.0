From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 0/9] SCTP updates for net-next-2.6
Date: Wed, 20 Apr 2011 15:24:23 +0800
Message-ID: <4DAE8A27.3040007@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57023 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752942Ab1DTHYX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 03:24:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

Here is a set of SCTP patches for net-next-2.6, also from vlad's
lksctp-dev tree.  Please apply.

Shan Wei (4):
      sctp: check parameter value of length in ERROR chunk
      sctp: check invalid value of length parameter in error cause
      sctp: remove redundant check when walking through a list of TLV parameters
      sctp: handle ootb packet in chunk order as defined

Vlad Yasevich (2):
      sctp: remove completely unsed EMPTY state
      sctp: bail from sctp_endpoint_lookup_assoc() if not bound.

Wei Yongjun (3):
      sctp: fix to check the source address of COOKIE-ECHO chunk
      sctp: make heartbeat information in sctp_make_heartbeat()
      sctp: move chunk from retransmit queue to abandoned list

 include/net/sctp/constants.h |   17 ++++-----
 include/net/sctp/sctp.h      |    2 -
 include/net/sctp/sm.h        |    4 +--
 include/net/sctp/structs.h   |    2 +-
 net/sctp/debug.c             |    1 -
 net/sctp/endpointola.c       |   20 ++++++++---
 net/sctp/input.c             |   15 --------
 net/sctp/outqueue.c          |    8 ++++-
 net/sctp/sm_make_chunk.c     |   44 +++++++++++++++++++-----
 net/sctp/sm_sideeffect.c     |    3 +-
 net/sctp/sm_statefuns.c      |   60 ++++++++++++++++++++++-----------
 net/sctp/sm_statetable.c     |   76 ------------------------------------------
 12 files changed, 106 insertions(+), 146 deletions(-)


