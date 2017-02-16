From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 0/4] ip vrf: updates to handle cgroup hiearchy and namespace nesting
Date: Thu, 16 Feb 2017 08:58:54 -0800
Message-ID: <1487264338-17588-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org,
        luto@amacapital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33542 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754904AbdBPQ7E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 11:59:04 -0500
Received: by mail-pf0-f173.google.com with SMTP id c73so6885521pfb.0
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 08:59:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More updates to ip vrf for 4.10. Major changes: handle vrf in an existing
cgroup hierarchy and handle vrf nesting in network namespaces.

Comparison of the netns in bpf code will be added once the kernel patch
is accepted.

David Ahern (4):
  ip vrf: Handle vrf in a cgroup hierarchy
  ip netns: refactor netns_identify
  ip vrf: Handle VRF nesting in namespace
  ip vrf: Detect invalid vrf name in pids command

 ip/ip_common.h |   1 +
 ip/ipnetns.c   |  47 +++++++-----
 ip/ipvrf.c     | 222 ++++++++++++++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 227 insertions(+), 43 deletions(-)

-- 
2.1.4
