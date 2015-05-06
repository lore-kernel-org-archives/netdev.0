From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 0/4] iproute2: exit code fixes
Date: Wed,  6 May 2015 09:57:59 -0700
Message-ID: <1430931483-28595-1-git-send-email-stephen@networkplumber.org>
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34124 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114AbbEFQ6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 12:58:01 -0400
Received: by pacyx8 with SMTP id yx8so14552609pac.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 09:58:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The exit code for ip command has always been 0 on success,
1 on syntax error, and 2 on kernel (netlink) error; but it isn't
documented and there were some regressions and places it was not
being done correctly.

Stephen Hemminger (4):
  ip: document exit code
  ip: return correct exit code on route failure
  ip: fix exit code for rule failures
  ip: fix exit code for addrlabel

 ip/ipaddrlabel.c | 6 +++---
 ip/iproute.c     | 2 +-
 ip/iprule.c      | 2 +-
 man/man8/ip.8    | 4 ++++
 4 files changed, 9 insertions(+), 5 deletions(-)

-- 
2.1.4
