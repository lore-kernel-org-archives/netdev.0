From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 0/3] Fix for IPsec leakage with SELinux enabled - V.04
Date: Mon, 09 Oct 2006 11:24:32 -0500
Message-ID: <452A77C0.5040108@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmorris@namei.org, sds@tycho.nsa.gov,
	paul.moore@hp.com, eparis@redhat.com, sgrubb@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:2633 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932965AbWJIQZT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 12:25:19 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a bug fix for the MLSXFRM patchset already queued for 2.6.19.

This version is just a repost of V.03 with the subject titles
fixed up, and the patches ported to davem's net-2.6.git as of today.

 include/linux/security.h        |   24 ++-----
 include/net/flow.h              |    2 
 include/net/xfrm.h              |    3 
 net/core/flow.c                 |   42 ++++++++----
 net/ipv4/xfrm4_policy.c         |    2 
 net/ipv6/xfrm6_policy.c         |    2 
 net/key/af_key.c                |    5 -
 net/xfrm/xfrm_policy.c          |  101 ++++++++++++++++++++++--------
 net/xfrm/xfrm_user.c            |    9 --
 security/dummy.c                |    3 
 security/selinux/include/xfrm.h |    3 
 security/selinux/xfrm.c         |   53 ++++++++++++---
 12 files changed, 162 insertions(+), 87 deletions(-)

