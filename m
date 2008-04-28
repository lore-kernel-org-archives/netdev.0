From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 0/9 net-next-2.6] [TIPC]: System & debug output modifications
Date: Mon, 28 Apr 2008 15:48:37 -0400
Message-ID: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33647 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933831AbYD1TwD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 15:52:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch set includes a number of fixes and cleanups for the code TIPC
uses to print its system and debug output. Please see each individual patch
for further description.

Summary:

 net/tipc/config.c     |    2 
 net/tipc/core.c       |    6 +
 net/tipc/core.h       |  124 ++++++++++++++++----------
 net/tipc/dbg.c        |  231 ++++++++++++++++++++++++-------------------------
 net/tipc/dbg.h        |   12 +--
 net/tipc/link.c       |   20 +++-
 net/tipc/msg.c        |   10 +-
 net/tipc/name_distr.c |    3 -
 8 files changed, 218 insertions(+), 190 deletions(-)

Allan Stephens (9):
      [TIPC]: Simplify log buffer resizing
      [TIPC]: Provide feedback when log buffer resizing fails
      [TIPC]: Fix recursive spinlock invocation in print buffer code
      [TIPC]: Fix null pointer dereference in debug code
      [TIPC]: Elimination of print buffer chaining
      [TIPC]: Cosmetic cleanup of print buffer code
      [TIPC]: Cosmetic cleanup of system & debug output declarations
      [TIPC]: Exclude debug-only print buffer code when not debugging
      [TIPC]: Update version number to TIPC 1.6.4

Thanks,
Al
