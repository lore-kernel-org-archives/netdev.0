From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next v3 0/2] ila: Precompute checksums
Date: Mon, 24 Aug 2015 09:45:40 -0700
Message-ID: <1440434742-4112603-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:19835 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751061AbbHXQpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 12:45:49 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7OGhkIC031614
	for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 09:45:49 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1wg64w09c0-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 09:45:49 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 921c7cba4a7f11e5ae8c0002c99293a0-12bfd240 for <netdev@vger.kernel.org>;	Mon,
 24 Aug 2015 09:45:47 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set:
 - Adds argument ot LWT build_state that holds a pointer to the fib
   configuration being applied to the new route
 - Adds support in ILA to precompute checksum difference for
   performance optimization

v2:
 - Move return argument in build_state to end of arguments

v3:
 - Update the signature for ip6_tun_build_state()


Tom Herbert (2):
  lwt: Add cfg argument to build_state
  ila: Precompute checksum difference for translations

 include/net/lwtunnel.h    |  3 +++
 net/core/lwtunnel.c       |  5 +++--
 net/ipv4/fib_semantics.c  | 17 ++++++++++-------
 net/ipv4/ip_tunnel_core.c |  2 ++
 net/ipv6/ila.c            | 19 +++++++++++++++++++
 net/ipv6/route.c          |  3 ++-
 net/mpls/mpls_iptunnel.c  |  1 +
 7 files changed, 40 insertions(+), 10 deletions(-)

-- 
1.8.1
