From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: [PATCH iproute2 v2 0/1] vxlan: support for modifying vxlan device
Date: Sat,  6 May 2017 11:37:42 -0700
Message-ID: <1494095863-21916-1-git-send-email-girish.moodalbail@oracle.com>
Cc: <netdev@vger.kernel.org>
To: <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:40668 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752375AbdEFSqm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 14:46:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

This patch adds support for modifying VXLAN device attributes. I have
refactored the vxlan_parse_opt() function to be more readable and not
use lot of bool variables.

I have tested my changes by running Linux Test Project's VXLAN
testcases, and I didn't see any regression.
---
v1->v2
- refactored vxlan_parse_opt() to not to use a bunch of
  foo_set variables

Girish Moodalbail (1):
  vxlan: Add support for modifying vxlan device attributes

 ip/iplink_vxlan.c | 251 +++++++++++++++++++++++++++++++-----------------------
 1 file changed, 143 insertions(+), 108 deletions(-)

-- 
1.8.3.1
