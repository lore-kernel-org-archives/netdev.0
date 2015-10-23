From: Joe Jin <joe.jin@oracle.com>
Subject: [PATCH 0/2] limit xen vnic max queues number to online cpu number
Date: Fri, 23 Oct 2015 15:53:58 +0800
Message-ID: <5629E796.5040203@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org
To: wei.liu2@citrix.com, Ian Campbell <ian.campbell@citrix.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25438 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbbJWHyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 03:54:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently xen vnic allowed to create lots of queues by set module param
max_queues(both netback and netfront), when queues number larger than
cpu number, it does not help for performance but need more cpu time.

This patchset limit netback and netfront max queues number to online
cpus number.

Joe Jin (2):
  xen-netback: limit xen vif max queues number to online cpus
  xen-front: limit vnic max_queues number to online cpus

 drivers/net/xen-netback/netback.c |   28 ++++++++++++++++++++++------
 drivers/net/xen-netfront.c        |   27 +++++++++++++++++++++------
 2 files changed, 43 insertions(+), 12 deletions(-)
