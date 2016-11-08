From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/2] Resend: Simplify and enhance vf_info parsing
Date: Tue,  8 Nov 2016 22:29:10 +0100
Message-ID: <20161108212912.27258-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:55495 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752163AbcKHV3Y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Nov 2016 16:29:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series got lost in a discussion about whether the code the
first patch removes is necessary or not - static analysis as well as my
tests showed it is not. Therefore resending this with updated
description of patch 1 to contain the discussion's gist.

Phil Sutter (2):
  ipaddress: Simplify vf_info parsing
  ipaddress: Print IFLA_VF_QUERY_RSS_EN setting

 ip/ipaddress.c | 52 ++++++++++++++++++----------------------------------
 1 file changed, 18 insertions(+), 34 deletions(-)

-- 
2.10.0
