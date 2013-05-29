From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH v3 0/2] Fix the SELinux dynamic network access controls
Date: Wed, 29 May 2013 13:36:18 -0400
Message-ID: <20130529173336.31888.29695.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: omoris@redhat.com, pwouters@redhat.com
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21682 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754614Ab3E2Rg0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 13:36:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take #3 ... two changes here: the first is a simple reordering of the
two patches and the second is stripping the SELinux patch (2/2 in this
patchset) of everything but the bare bones changes needed to fix the
problem in the 3.10-rcX tree.

Enjoy.

---

Paul Moore (2):
      xfrm: force a garbage collection after deleting a policy
      selinux: fix the labeled xfrm/IPsec reference count handling

 include/net/xfrm.h      |    5 +++++
 net/key/af_key.c        |    4 ++++
 net/xfrm/xfrm_policy.c  |    3 ++-
 net/xfrm/xfrm_user.c    |    2 ++
 security/selinux/xfrm.c |   34 ++++++++++++++--------------------
 5 files changed, 27 insertions(+), 21 deletions(-)
