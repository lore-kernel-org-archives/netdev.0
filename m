From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-26 0/5] cxgb4vf: minor bug fixes
Date: Fri, 11 Feb 2011 17:00:18 -0800
Message-ID: <1297472423-15672-1-git-send-email-leedom@chelsio.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:9029 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757893Ab1BLBA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 20:00:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several minor bug fixes in the cxgb4vf driver ...

[01/05]: Virtual Interfaces are always up ...
[02/05]: Check driver parameters in the right place ...
[03/05]: Behave properly when CONFIG_DEBUG_FS isn't defined ...
[04/05]: Quiesce Virtual Interfaces on shutdown ...
[05/05]: Use defined Mailbox Timeout

 drivers/net/cxgb4vf/cxgb4vf_main.c |  110 ++++++++++++++++++++++++++++--------
 drivers/net/cxgb4vf/t4vf_hw.c      |    2 +-
 2 files changed, 88 insertions(+), 24 deletions(-)

