From: Andy Zhou <azhou@nicira.com>
Subject: [patch net-next 0/4] Refactor IP defragmentation and fragmenation APIs for OVS conntrack support
Date: Mon,  9 Mar 2015 01:01:34 -0700
Message-ID: <1425888098-21875-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:37649 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751254AbbCIIKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 04:10:51 -0400
Received: by mail-pa0-f44.google.com with SMTP id rd3so46929439pab.5
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 01:10:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are the patches refactors the core APIs for both IPv4 and IPv6.

The intended use for openvswitch has been posted in the eariler RFC: 

http://lists.openwall.net/netdev/2015/03/02/220

Andy Zhou (4):
  net: add 'const' to __ipv6_select_ident()'s input address parameter
  net: add ipv6_select_ident_by_addr() API
  net: refactor IPv4 and IPv6 fragmentation APIs
  net: refactor IPv4 and IPv6 defragmentation APIs

 include/net/ip.h                            |   4 +
 include/net/ipv6.h                          |   7 ++
 include/net/netfilter/ipv6/nf_defrag_ipv6.h |   2 +
 net/ipv4/ip_fragment.c                      |  15 ++-
 net/ipv4/ip_output.c                        | 113 +++++++++++---------
 net/ipv6/ip6_output.c                       | 157 +++++++++++++++++-----------
 net/ipv6/netfilter/nf_conntrack_reasm.c     |  18 +++-
 net/ipv6/output_core.c                      |  17 ++-
 8 files changed, 208 insertions(+), 125 deletions(-)

-- 
1.9.1
