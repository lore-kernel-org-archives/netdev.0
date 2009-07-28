From: Hannes Eder <heder@google.com>
Subject: [PATCH v2 0/2] IPVS: make use of pr_fmt and friends
Date: Tue, 28 Jul 2009 22:35:34 +0200
Message-ID: <20090728203414.7654.73236.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org,
	Jan Engelhardt <jengelh@medozas.de>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following series makes use of pr_fmt and friends instead of printk.

v2: use printk instead of pr_debug


Hannes Eder (2):
      IPVS: use pr_err and friends instead of IP_VS_ERR and friends
      IPVS: use pr_fmt


 include/net/ip_vs.h                     |  116 +++++++++++++++----------------
 net/netfilter/ipvs/ip_vs_app.c          |    3 +
 net/netfilter/ipvs/ip_vs_conn.c         |   15 ++--
 net/netfilter/ipvs/ip_vs_core.c         |   25 ++++---
 net/netfilter/ipvs/ip_vs_ctl.c          |   59 ++++++++--------
 net/netfilter/ipvs/ip_vs_dh.c           |    5 +
 net/netfilter/ipvs/ip_vs_est.c          |    4 +
 net/netfilter/ipvs/ip_vs_ftp.c          |    7 +-
 net/netfilter/ipvs/ip_vs_lblc.c         |    7 +-
 net/netfilter/ipvs/ip_vs_lblcr.c        |    9 ++
 net/netfilter/ipvs/ip_vs_lc.c           |    3 +
 net/netfilter/ipvs/ip_vs_nq.c           |    3 +
 net/netfilter/ipvs/ip_vs_proto.c        |    9 ++
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |    7 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |    3 +
 net/netfilter/ipvs/ip_vs_proto_udp.c    |    3 +
 net/netfilter/ipvs/ip_vs_rr.c           |    3 +
 net/netfilter/ipvs/ip_vs_sched.c        |   39 ++++++----
 net/netfilter/ipvs/ip_vs_sed.c          |    3 +
 net/netfilter/ipvs/ip_vs_sh.c           |    5 +
 net/netfilter/ipvs/ip_vs_sync.c         |   49 +++++++------
 net/netfilter/ipvs/ip_vs_wlc.c          |    3 +
 net/netfilter/ipvs/ip_vs_wrr.c          |    5 +
 net/netfilter/ipvs/ip_vs_xmit.c         |    3 +
 24 files changed, 228 insertions(+), 160 deletions(-)
