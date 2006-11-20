From: James Morris <jmorris@namei.org>
Subject: [GIT] Netlabel patches for net-2.6.20
Date: Mon, 20 Nov 2006 16:19:14 -0500 (EST)
Message-ID: <XMMS.LNX.4.64.0611201618400.30678@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:27565 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S966763AbWKTVTQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 16:19:16 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave, 

Please pull per below.


The following changes since commit e0355a0f485e2b4c29d1df2b4a641f1e0c6fb68c:
  Andrea Bittau:
        [DCCP] CCID2: Code optimizations

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/selinux-net-2.6.20

James Morris:
      Compile fix for

Paul Moore:
      NetLabel: use gfp_t instead of int where it makes sense
      NetLabel: convert the unlabeled accept flag to use RCU
      NetLabel: change netlbl_secattr_init() to return void
      NetLabel: make netlbl_lsm_secattr struct easier/quicker to understand
      NetLabel: check for a CIPSOv4 option before we do call into the CIPSOv4 layer
      NetLabel: add tag verification when adding new CIPSOv4 DOI definitions
      NetLabel: fixup the handling of CIPSOv4 tags to allow for multiple tag types
      NetLabel: return the correct error for translated CIPSOv4 tags
      NetLabel: use the correct CIPSOv4 MLS label limits
      NetLabel: use cipso_v4_doi_search() for local CIPSOv4 functions
      NetLabel: SELinux cleanups
      SELinux: peer secid consolidation for external network labeling
      NetLabel: honor the audit_enabled flag

 include/net/cipso_ipv4.h                    |    4 
 include/net/netlabel.h                      |   21 ++-
 net/ipv4/cipso_ipv4.c                       |  159 +++++++++++---------
 net/netlabel/netlabel_cipso_v4.c            |   26 ++-
 net/netlabel/netlabel_domainhash.c          |   48 +++---
 net/netlabel/netlabel_kapi.c                |   11 +
 net/netlabel/netlabel_unlabeled.c           |   36 +++-
 net/netlabel/netlabel_user.c                |    7 +
 security/selinux/hooks.c                    |   53 ++-----
 security/selinux/include/objsec.h           |    2 
 security/selinux/include/security.h         |    4 
 security/selinux/include/selinux_netlabel.h |   43 ++---
 security/selinux/include/xfrm.h             |    5 -
 security/selinux/ss/services.c              |  219 +++++++++++++--------------
 security/selinux/xfrm.c                     |   33 ----
 15 files changed, 331 insertions(+), 340 deletions(-)
