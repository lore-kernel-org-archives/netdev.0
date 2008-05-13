From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 0/5 net-next-2.6] [TIPC]: Network topology server modifications
Date: Tue, 13 May 2008 14:17:40 -0400
Message-ID: <1210702665-5012-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35566 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755871AbYEMSST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 14:18:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch set includes a number of enhancements and fixes to TIPC's network
topology service.  Please see each individual patch for further description.

Summary:

 net/tipc/core.c   |    3 -
 net/tipc/subscr.c |  250 +++++++++++++++++++++++++++++------------------------
 net/tipc/subscr.h |   34 +++++--
 3 files changed, 159 insertions(+), 128 deletions(-)

Allan Stephens (5):
      [TIPC]: Add support for customized subscription overlap handling
      [TIPC]: Add support for customized subscription endianness
      [TIPC]: Fix bug in topology server byte swapping routine
      [TIPC]: Consolidate subscriber & subscriber port references
      [TIPC]: Cosmetic cleanup of topology service code

Thanks,
Al

