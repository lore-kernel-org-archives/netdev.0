From: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Subject: [PATCH net-next 0/2] flower: add MPLS matching support
Date: Sat, 22 Apr 2017 16:52:45 -0400
Message-ID: <1492894367-11637-1-git-send-email-benjamin.lahaise@netronome.com>
Cc: Benjamin LaHaise <bcrl@kvack.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:35291 "EHLO
        mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425662AbdDVUx6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 16:53:58 -0400
Received: by mail-qk0-f171.google.com with SMTP id f76so13399617qke.2
        for <netdev@vger.kernel.org>; Sat, 22 Apr 2017 13:53:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>

This patch series adds support for parsing MPLS flows in the flow dissector
and the flower classifier.  Each of the MPLS TTL, BOS, TC and Label fields
can be used for matching.

v2: incorporate style feedback, move #defines to linux/include/mpls.h
Note: this omits Jiri's request to remove tabs between the type and 
field names in struct declarations.  This would be inconsistent with 
numerous other struct definitions.

Benjamin LaHaise (2):
  flow_dissector: add mpls support (v2)
  cls_flower: add support for matching MPLS fields (v2)

 include/linux/mpls.h         |  5 +++
 include/net/flow_dissector.h |  8 +++++
 include/uapi/linux/pkt_cls.h |  5 +++
 net/core/flow_dissector.c    | 25 +++++++++++++--
 net/sched/cls_flower.c       | 74 ++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 114 insertions(+), 3 deletions(-)

-- 
2.7.4
