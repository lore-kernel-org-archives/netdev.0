From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2-6 0/3] caif: Code cleanup
Date: Mon, 11 Apr 2011 22:43:49 +0200
Message-ID: <1302554632-13638-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:46879 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755648Ab1DKUog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 16:44:36 -0400
Received: from terra-smin.broadpark.no ([80.202.8.13])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LJI00ABF9LXVC00@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Mon, 11 Apr 2011 22:44:21 +0200 (CEST)
Received: from localhost.localdomain ([80.203.137.187])
 by terra-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LJI0082H9LXJMZ0@terra-smin.broadpark.no> for
 netdev@vger.kernel.org; Mon, 11 Apr 2011 22:44:21 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

Hi Dave.

Here is some code cleanup for CAIF for net-next-2.6.
These patches can be applied independently of the other
bug-fix patches I just sent.=20

I'm also including an old rfc/patch from Stephen Hemminger.
I hope this is OK.

Regards,
Sjur

Sjur Br=C3=A6ndeland (2):
  caif: Don't resend if dev_queue_xmit fails.
  caif: Add BUG_ON if dev_info is missing in packet

Stephen Hemminger (1):
  caif: code cleanup

 include/net/caif/caif_dev.h |   27 +-----
 include/net/caif/cfctrl.h   |   12 +---
 include/net/caif/cfmuxl.h   |    2 -
 include/net/caif/cfpkt.h    |   75 ------------------
 include/net/caif/cfsrvl.h   |    3 +-
 net/caif/caif_config_util.c |    6 +-
 net/caif/caif_dev.c         |   45 +++---------
 net/caif/caif_socket.c      |   35 +--------
 net/caif/cfcnfg.c           |    2 +-
 net/caif/cfctrl.c           |   75 ++----------------
 net/caif/cfdgml.c           |    7 +--
 net/caif/cffrml.c           |    8 +--
 net/caif/cfmuxl.c           |   45 +----------
 net/caif/cfpkt_skbuff.c     |  178 +----------------------------------=
-------
 net/caif/cfserl.c           |    7 +--
 net/caif/cfsrvl.c           |    7 +--
 net/caif/cfutill.c          |    7 +--
 net/caif/cfveil.c           |    5 +-
 net/caif/cfvidl.c           |    5 +-
 19 files changed, 46 insertions(+), 505 deletions(-)

