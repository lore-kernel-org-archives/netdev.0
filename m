From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC v2 0/2] ipv6: allow temporary address management for user-created addresses
Date: Tue, 19 Nov 2013 11:43:27 +0100
Message-ID: <1384857809-6573-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org, hannes@stressinduktion.org,
	vyasevich@gmail.com, dcbw@redhat.com, David.Laight@ACULAB.COM
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:50380 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701Ab3KSKnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 05:43:33 -0500
Received: by mail-ee0-f48.google.com with SMTP id e49so3084090eek.7
        for <netdev@vger.kernel.org>; Tue, 19 Nov 2013 02:43:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both kernel patches were modified, see details in each patch description.
No modification to iproute2 patches was done.

Jiri Pirko (2):
  ipv6 addrconf: extend ifa_flags to u32
  ipv6 addrconf: introduce IFA_F_MANAGETEMPADDR to tell kernel to manage
    temporary addresses

 include/net/addrconf.h       |   4 +-
 include/net/if_inet6.h       |   2 +-
 include/uapi/linux/if_addr.h |   5 ++
 net/ipv6/addrconf.c          | 197 +++++++++++++++++++++++++------------------
 4 files changed, 122 insertions(+), 86 deletions(-)

-- 
1.8.3.1
