From: James Morris <jmorris@namei.org>
Subject: [GIT] SELinux/IPsec: bugfix pull request
Date: Fri, 6 Oct 2006 13:21:09 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610061319170.6386@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:12454 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1422765AbWJFRVL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Oct 2006 13:21:11 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave, please pull the following bugfix patches, for the IPsec/SELinux 
and related labeled network code.


The following changes since commit e77119c769b71c3f10b35d66988a3e279d30388c:
  James Morris:
        Merge ../../linux-2.6 into linus

are found in the git repository at:

  git://git.infradead.org/~jmorris/selinux-2.6.git

James Morris:
      IPsec: propagate security module errors up from flow_cache_lookup

paul.moore@hp.com:
      NetLabel: use SECINITSID_UNLABELED for a base SID

Venkat Yekkirala:
      IPsec: correct semantics for SELinux policy matching
      IPsec: fix handling of errors for socket policies

 include/linux/security.h        |   24 +++------
 include/net/flow.h              |    2 -
 include/net/xfrm.h              |    3 +
 net/core/flow.c                 |   42 +++++++++++-----
 net/ipv4/xfrm4_policy.c         |    2 -
 net/ipv6/xfrm6_policy.c         |    2 -
 net/key/af_key.c                |    5 --
 net/xfrm/xfrm_policy.c          |  101 +++++++++++++++++++++++++++++----------
 net/xfrm/xfrm_user.c            |    9 ---
 security/dummy.c                |    3 +
 security/selinux/include/xfrm.h |    3 +
 security/selinux/ss/services.c  |   29 +++--------
 security/selinux/xfrm.c         |   53 ++++++++++++++++----
 13 files changed, 171 insertions(+), 107 deletions(-)

-- 
James Morris
<jmorris@namei.org>
