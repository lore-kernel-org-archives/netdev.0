From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/2] TCP experimental option for SMC rendezvous
Date: Mon, 16 Oct 2017 17:42:00 +0200
Message-ID: <20171016154202.72635-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:53558 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752477AbdJPPmL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 11:42:11 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9GFdrSf001359
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 11:42:10 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dmvrst0sd-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 11:42:10 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Mon, 16 Oct 2017 16:42:08 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

SMC-capability is to be negotiated with a TCP experimental option.
As requested during code review of our previous approach using
netfilter hooks, here's a new version. It touches tcp-code in the
first patch and exploits the new tcp flag in the smc-code.

Kind regards, Ursula

Ursula Braun (2):
  tcp: TCP experimental option for SMC
  smc: add SMC rendezvous protocol

 include/linux/tcp.h      |  9 ++++--
 include/net/inet_sock.h  |  3 +-
 include/net/tcp.h        |  8 ++++++
 net/ipv4/tcp.c           |  6 ++++
 net/ipv4/tcp_input.c     | 45 ++++++++++++++++++++++++++++++
 net/ipv4/tcp_minisocks.c | 20 ++++++++++++++
 net/ipv4/tcp_output.c    | 71 ++++++++++++++++++++++++++++++++++++++++++++++--
 net/smc/af_smc.c         | 21 +++++++++++++-
 8 files changed, 176 insertions(+), 7 deletions(-)

-- 
2.13.5
