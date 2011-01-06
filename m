From: Ferenc Wagner <wferi@niif.hu>
Subject: [PATCH 0/2] Re: spurious netconsole: network logging stopped messages
Date: Thu,  6 Jan 2011 16:11:18 +0100
Message-ID: <cover.1294326001.git.wferi@niif.hu>
References: <87bp3yq60w.fsf@tac.ki.iif.hu>
Cc: Ferenc Wagner <wferi@niif.hu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs22.lvs.iif.hu ([193.225.14.172]:51318 "EHLO rs22.lvs.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752683Ab1AFPr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 10:47:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've been running with these two patches for a couple of days now.
I don't understand the bridge case: why should netconsole stop logging
on a bridge device which lost a slave?  Or does NETDEV_BONDING_DESLAVE
mean something else?

Anyway, I think the first patch fixes a real bug and the second makes
the kernel message clearer, independently of its cause.

Regards,
Feri.

Ferenc Wagner (2):
  netconsole: don't announce stopping if nothing happened
  netconsole: clarify stopping message

 drivers/net/netconsole.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

