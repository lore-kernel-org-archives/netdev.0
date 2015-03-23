From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2 0/8] ipv6: RFC7217 stable privacy addresses implementation
Date: Mon, 23 Mar 2015 23:35:58 +0100
Message-ID: <cover.1427149704.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: ek@google.com, fgont@si6networks.com, lorenzo@google.com,
	hideaki.yoshifuji@miraclelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:46105 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752214AbbCWWgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:36:14 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id F31DB2080E
	for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 18:36:10 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

this is an implementation of basic support for RFC7217 stable privacy
addresses. Please review and consider for net-next.

Bye and thanks,
Hannes

v2:
* Correct references to RFC 7212 -> RFC 7217 in documentation patch (thanks, Eric!)

Hannes Frederic Sowa (8):
  lib: EXPORT_SYMBOL sha_init
  ipv6: introduce secret_stable to ipv6_devconf
  ipv6: generation of stable privacy addresses for link-local and
    autoconf
  ipv6: introduce IFA_F_STABLE_PRIVACY flag
  ipv6: collapse state_lock and lock
  ipv6: do retries on stable privacy addresses
  ipv6: introduce idgen_delay and idgen_retries knobs
  ipv6: add documentation for stable_secret, idgen_delay and
    idgen_retries knobs

 Documentation/networking/ip-sysctl.txt |  25 +++
 include/linux/ipv6.h                   |   4 +
 include/net/if_inet6.h                 |   4 +-
 include/net/netns/ipv6.h               |   2 +
 include/uapi/linux/if_addr.h           |   1 +
 include/uapi/linux/if_link.h           |   1 +
 include/uapi/linux/ipv6.h              |   1 +
 lib/sha1.c                             |   1 +
 net/ipv6/addrconf.c                    | 293 ++++++++++++++++++++++++++++++---
 net/ipv6/af_inet6.c                    |   2 +
 net/ipv6/sysctl_net_ipv6.c             |  16 ++
 11 files changed, 321 insertions(+), 29 deletions(-)

-- 
2.1.0
