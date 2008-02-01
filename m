From: acme@ghostprotocols.net
Subject: [PATCHES 0/5]: Add hashinfo member to struct proto and get net/ structs back on a diet
Date: Fri,  1 Feb 2008 20:23:31 -0200
Message-ID: <47a39bf3.1087460a.06ae.ffffd95f@mx.google.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:61339 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718AbYBAWXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 17:23:49 -0500
Received: by wx-out-0506.google.com with SMTP id h31so1986032wxd.4
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2008 14:23:48 -0800 (PST)
In-Reply-To: y
References: y
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

	Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.25

	There are many more structs that have holes, they seem to crop up, even
on DCCP! People should use some paholing 8-)

	I'll prepare another round after carnival, and also will look at using
sparse and/or Uli's libdisasm and/or DeHydra to find struct member accesses in
functions to correlate that with struct layout when doing automatic struct
member reorgs, so as not to step into Eric's fast path 8-P

Best Regards,

- Arnaldo

 include/linux/dccp.h               |    2 -
 include/net/if_inet6.h             |    6 +--
 include/net/inet6_hashtables.h     |    2 -
 include/net/inet_connection_sock.h |    8 +----
 include/net/inet_hashtables.h      |   51 +++++---------------------------
 include/net/inet_timewait_sock.h   |    2 -
 include/net/sock.h                 |    3 +
 net/dccp/dccp.h                    |    2 -
 net/dccp/ipv4.c                    |   18 ++++-------
 net/dccp/ipv6.c                    |   20 +++++-------
 net/dccp/proto.c                   |   18 +----------
 net/ipv4/inet_connection_sock.c    |    8 +----
 net/ipv4/inet_hashtables.c         |   58 ++++++++++++++++++++++++++++++-------
 net/ipv4/tcp.c                     |    2 -
 net/ipv4/tcp_ipv4.c                |   31 +++++--------------
 net/ipv6/inet6_hashtables.c        |    4 +-
 net/ipv6/tcp_ipv6.c                |   19 +++++-------
 17 files changed, 108 insertions(+), 146 deletions(-)
