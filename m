From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next 0/2] sock_diag: introducing udp_info
Date: Mon,  5 Oct 2015 15:55:25 -0400
Message-ID: <1444074927-27098-1-git-send-email-kraigatgoog@gmail.com>
Cc: kraigatgoog@gmail.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:35574 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752925AbbJETza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 15:55:30 -0400
Received: by qgt47 with SMTP id 47so159781832qgt.2
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 12:55:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

These patches introduce a structure for reporting udp statistics
through netlink.  Simple datagram and byte counters are included.

Craig Gallek (2):
  sock_diag: create udp_info for udp socket stats
  sock_diag: initial udp_info metrics

 include/linux/inet_diag.h      |  1 +
 include/linux/udp.h            |  7 +++++++
 include/net/udp.h              |  2 ++
 include/uapi/linux/inet_diag.h |  3 ++-
 include/uapi/linux/udp.h       |  7 +++++++
 net/dccp/diag.c                |  1 +
 net/ipv4/inet_diag.c           | 25 ++++++++++++-------------
 net/ipv4/tcp_diag.c            |  1 +
 net/ipv4/udp.c                 | 26 ++++++++++++++++++++++++--
 net/ipv4/udp_diag.c            | 18 ++++++++++++++++--
 net/ipv6/udp.c                 | 14 +++++++++++++-
 11 files changed, 86 insertions(+), 19 deletions(-)

-- 
2.6.0.rc2.230.g3dd15c0
