From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/9] tc: m_xt: Two fixes and a smaller review
Date: Fri, 10 Jun 2016 13:41:59 +0200
Message-ID: <1465558928-19657-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:43626 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753316AbcFJLnG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 07:43:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first two patches of this series fix segfaults when calling tc in a
specific way. Basically they are caused by some libxtables quirks the xt
action did not cover.

The remaining patches are more or less cosmetic code cleanups.

Phil Sutter (9):
  tc: m_xt: Prevent segfault with standard targets
  tc: m_xt: Fix segfault when adding multiple actions at once
  tc: m_xt: Fix indenting
  tc: m_xt: Get rid of one indentation level in parse_ipt()
  tc: m_xt: Drop unused variable fw in parse_ipt()
  tc: m_xt: Get rid of rargc in parse_ipt()
  tc: m_xt: Get rid of iargc variable in parse_ipt()
  tc: m_xt: Simplify argc adjusting in parse_ipt()
  tc: m_xt: Introduce get_xtables_target_opts()

 tc/m_xt.c | 188 ++++++++++++++++++++++++++++++--------------------------------
 1 file changed, 91 insertions(+), 97 deletions(-)

-- 
2.8.2
