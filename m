From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 0/2] ipv6: allow temporary address management for user-created addresses
Date: Mon, 11 Nov 2013 15:49:17 +0100
Message-ID: <1384181359-23199-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org, hannes@stressinduktion.org,
	vyasevich@gmail.com, dcbw@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:47032 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753501Ab3KKOtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 09:49:24 -0500
Received: by mail-ea0-f178.google.com with SMTP id a10so2228424eae.23
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 06:49:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (2):
  ipv6 addrconf: extend ifa_flags to u32
  ipv6 addrconf: introduce IFA_F_MANAGETEMPADDR to tell kernel to manage
    temporary addresses

 include/net/if_inet6.h       |   2 +-
 include/uapi/linux/if_addr.h |   5 ++
 net/ipv6/addrconf.c          | 181 +++++++++++++++++++++++++------------------
 3 files changed, 110 insertions(+), 78 deletions(-)

-- 
1.8.3.1
