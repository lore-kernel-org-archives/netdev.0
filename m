From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH RFC 0/3] Add generic size table for qdiscs
Date: Thu, 17 Jul 2008 13:09:21 +0300
Message-ID: <20080717100921.3327.3324.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.dnainternet.fi ([87.94.96.112]:39142 "EHLO
	smtp2.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753840AbYGQKJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 06:09:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Resend one patch per mail]

Here's first version of generic size table feature. Didn't get chance to
test too much yet but hfsc&sfq seems to be ok.

---

Jussi Kivilinna (3):
      net_sched: Add size table for qdiscs
      net_sched: Add accessor function for packet length for qdiscs
      net_sched: Add qdisc_enqueue wrapper


 include/linux/pkt_sched.h |   21 ++++++++
 include/linux/rtnetlink.h |    1
 include/net/pkt_sched.h   |    1
 include/net/sch_generic.h |   50 +++++++++++++++++--
 net/core/dev.c            |    3 +
 net/mac80211/wme.c        |    2 -
 net/sched/sch_api.c       |  117 ++++++++++++++++++++++++++++++++++++++++++++-
 net/sched/sch_atm.c       |    6 +-
 net/sched/sch_cbq.c       |   19 +++----
 net/sched/sch_dsmark.c    |    4 +-
 net/sched/sch_fifo.c      |    2 -
 net/sched/sch_generic.c   |    1
 net/sched/sch_gred.c      |   12 ++---
 net/sched/sch_hfsc.c      |   16 +++---
 net/sched/sch_htb.c       |   12 ++---
 net/sched/sch_netem.c     |   26 ++++++----
 net/sched/sch_prio.c      |    5 +-
 net/sched/sch_red.c       |    4 +-
 net/sched/sch_sfq.c       |   16 +++---
 net/sched/sch_tbf.c       |   12 +++--
 net/sched/sch_teql.c      |    6 +-
 21 files changed, 259 insertions(+), 77 deletions(-)

--
