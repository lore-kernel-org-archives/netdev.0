From: Stefano Brivio <sbrivio@redhat.com>
Subject: [iproute PATCH v2 0/3] ss: netlink_show_one() clean-up, minor output fix
Date: Tue, 31 Oct 2017 18:47:53 +0100
Message-ID: <cover.1509471877.git.sbrivio@redhat.com>
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41924 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751565AbdJaRsh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 13:48:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patches 1/3 and 2/3 streamline process context prints in
netlink_show_one(). Patch 3/3 fixes a display issue happening
when Netid or State columns are not displayed.

In general, the output layout of 'ss', also in the cases handled
here, still has a number of issues. I will address further issues
more structurally in a later patchset.

Stefano Brivio (3):
  ss: Remove useless width specifier in process context print
  ss: Streamline process context printing in netlink_show_one()
  ss: Fix width calculations when Netid or State columns are missing

v2: Coding style fixes in 3/3

 misc/ss.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

-- 
2.9.4
