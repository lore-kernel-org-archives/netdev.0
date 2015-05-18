From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2 00/10] RED and GRED fixes, plus TCA_GRED_LIMIT support
Date: Mon, 18 May 2015 11:35:04 -0400
Message-ID: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Cc: David Ward <david.ward@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-1.mit.edu ([18.9.25.12]:45704 "EHLO
	dmz-mailsec-scanner-1.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932248AbbERPfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:35:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please note that the final patch in this series adds tc command support for the
TCA_GRED_LIMIT attribute, which was accepted into net-next. However, it follows
the other patches in this series, which are bug fixes and improvements that can
be applied to the master branch of iproute2.

Signed-off-by: David Ward <david.ward@ll.mit.edu>

David Ward (10):
  tc: red, gred: Rename overloaded variable wlog
  tc: red, gred: Fix format specifier in burst size warning
  tc: red, gred: Notify when using the default value for "bandwidth"
  tc: red: Mark "bandwidth" parameter as optional in usage text
  tc: gred: Fix whitespace issues in code
  tc: gred: Print usage text if no arguments appear after "gred"
  tc: gred: Improve parameter/statistics output
  tc: gred: Handle unsigned values properly in option parsing/printing
  tc: gred: Adopt the term VQ in the command syntax and output
  tc: gred: Add support for TCA_GRED_LIMIT attribute

 include/linux/pkt_sched.h |    3 +-
 tc/q_gred.c               |  204 +++++++++++++++++++++++++--------------------
 tc/q_red.c                |   27 +++---
 3 files changed, 131 insertions(+), 103 deletions(-)
