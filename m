From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 0/3] new SCTP sockets APIs
Date: Mon, 18 Apr 2011 11:24:33 +0800
Message-ID: <4DABAEF1.1010506@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51000 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752442Ab1DRDYb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 23:24:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset implement some new sockets APIs for net-next-2.6.

Wei Yongjun (3):
  sctp: implement socket option SCTP_GET_ASSOC_ID_LIST
  sctp: change auth event type name to SCTP_AUTHENTICATION_EVENT
  sctp: implement event notification SCTP_SENDER_DRY_EVENT

 include/net/sctp/sm.h       |    1 +
 include/net/sctp/ulpevent.h |    3 ++
 include/net/sctp/user.h     |   33 ++++++++++++++++++++++++++-
 net/sctp/sm_statefuns.c     |   24 +++++++++++++++++++
 net/sctp/sm_statetable.c    |    2 +-
 net/sctp/socket.c           |   52 +++++++++++++++++++++++++++++++++++++++++++
 net/sctp/ulpevent.c         |   30 ++++++++++++++++++++++++-
 7 files changed, 142 insertions(+), 3 deletions(-)


