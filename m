From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: [PATCH ipsec-next 0/2] xfrm: scalability enhancements for policy database
Date: Mon, 12 May 2014 15:45:23 +0200
Message-ID: <1399902325-1788-1-git-send-email-christophe.gouault@6wind.com>
Cc: netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:59868 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883AbaELNpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 09:45:45 -0400
Received: by mail-wi0-f178.google.com with SMTP id hm4so4501911wib.11
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 06:45:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset enables to hash more policies than just non-prefixed
ones: hash policies whose prefix lengths are greater or equal to
configurable thresholds.

These thresholds are configured via /proc entries:

/proc/sys/net/ipv4/xfrm4_policy_hash_tresh: 32 32
/proc/sys/net/ipv6/xfrm6_policy_hash_tresh: 128 128

Christophe Gouault (2):
      xfrm: hash prefixed policies based on preflen thresholds
      xfrm: configure policy hash table thresholds by /proc

 include/net/netns/xfrm.h |   8 +++
 include/net/xfrm.h       |   1 +
 net/ipv4/xfrm4_policy.c  |  67 ++++++++++++++++++++++
 net/ipv6/xfrm6_policy.c  |  67 ++++++++++++++++++++++
 net/xfrm/xfrm_hash.h     |  76 +++++++++++++++++++++----
 net/xfrm/xfrm_policy.c   | 142 +++++++++++++++++++++++++++++++++++++++++++++--
 net/xfrm/xfrm_sysctl.c   |   3 +
 7 files changed, 348 insertions(+), 16 deletions(-)

Best Regards,
Christophe
