From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 0/4] Namespacify inet_peer_* sysctl knobs
Date: Wed, 17 Feb 2016 12:09:54 +0200
Message-ID: <1455703798-15258-1-git-send-email-kernel@kyup.com>
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:34986 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933451AbcBQKKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 05:10:03 -0500
Received: by mail-wm0-f47.google.com with SMTP id c200so204866840wme.0
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 02:10:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series make the inet_peer ttl sysctls to be namespace aware. 

Patch 1 adds a namespace association to the inet_peer_base struct, 
which in turn is used to make the sysctls namespace aware. The 
rest of the patches are straightforward. 

Nikolay Borisov (4):
  inetpeer: Add net namespace assosication in inet_peer_base
  inetpeer: Namespacify inet_peer_maxttl sysctl knob
  inetpeer: Namespacify inet_peer_minttl sysctl knob
  inetpeer: Namespacify inet_peer_threshold sysctl knob

 include/net/inetpeer.h     |  1 +
 include/net/ip.h           |  5 -----
 include/net/netns/ipv4.h   |  4 ++++
 net/ipv4/inetpeer.c        | 15 ++++++---------
 net/ipv4/route.c           |  1 +
 net/ipv4/sysctl_net_ipv4.c | 47 ++++++++++++++++++++++++----------------------
 6 files changed, 37 insertions(+), 36 deletions(-)

-- 
2.5.0
