From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] ipv6: allow temporary address management for user-created addresses
Date: Fri,  6 Dec 2013 09:45:20 +0100
Message-ID: <1386319522-2102-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org, hannes@stressinduktion.org,
	vyasevich@gmail.com, dcbw@redhat.com, David.Laight@ACULAB.COM
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:38475 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756102Ab3LFIp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 03:45:27 -0500
Received: by mail-ea0-f178.google.com with SMTP id d10so146413eaj.37
        for <netdev@vger.kernel.org>; Fri, 06 Dec 2013 00:45:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (2):
  ipv6 addrconf: extend ifa_flags to u32
  ipv6 addrconf: introduce IFA_F_MANAGETEMPADDR to tell kernel to manage
    temporary addresses

 include/net/addrconf.h       |   4 +-
 include/net/if_inet6.h       |   2 +-
 include/uapi/linux/if_addr.h |   5 ++
 net/ipv6/addrconf.c          | 201 +++++++++++++++++++++++++------------------
 4 files changed, 126 insertions(+), 86 deletions(-)

-- 
1.8.3.1
