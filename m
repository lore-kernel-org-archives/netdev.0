From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-26 0/4] cxgb4vf: minor bug fixes -- revised patch set
Date: Mon, 14 Feb 2011 14:56:21 -0800
Message-ID: <1297724185-27452-1-git-send-email-leedom@chelsio.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11437 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015Ab1BNW43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 17:56:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This is the same as the previous patch set but with the unacceptable patch
removed.  Let me know if there's anything else I should do.  Thanks and
sorry for not know the rules about that unacceptable patch.

[01/04]: Check driver parameters in the right place ...
[02/04]: Behave properly when CONFIG_DEBUG_FS isn't defined ...
[03/04]: Quiesce Virtual Interfaces on shutdown ...
[04/04]: Use defined Mailbox Timeout

 drivers/net/cxgb4vf/cxgb4vf_main.c |   80 +++++++++++++++++++++++++++---------
 drivers/net/cxgb4vf/t4vf_hw.c      |    2 +-
 2 files changed, 61 insertions(+), 21 deletions(-)

