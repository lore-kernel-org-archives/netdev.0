From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/2 v2] sctp: RCU protection when accessing assoc members for procfs
Date: Thu,  6 Dec 2012 20:25:03 +0100
Message-ID: <cover.1354821623.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, vyasevich@gmail.com, nhorman@tuxdriver.com
To: linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:57175
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755411Ab2LFTZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 14:25:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

@Dave: This is a respin of the following patches:
  [PATCH] sctp: proc: protect bind_addr->address_list accesses with rcu_read_lock()
  [PATCH] sctp: Add RCU protection to assoc->transport_addr_list

Thomas Graf (2):
  sctp: proc: protect bind_addr->address_list accesses with
    rcu_read_lock()
  sctp: Add RCU protection to assoc->transport_addr_list

 include/net/sctp/structs.h |  2 ++
 net/sctp/associola.c       |  6 +++---
 net/sctp/proc.c            | 21 ++++++++++++++++++---
 net/sctp/transport.c       | 18 +++++++++++++-----
 4 files changed, 36 insertions(+), 11 deletions(-)

-- 
1.7.11.7
