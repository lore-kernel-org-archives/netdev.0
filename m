From: zyjzyj2000@gmail.com
Subject: [PATCH net-next 1/1] ixgbe: add fiber tranceiver plug/unplug notifier
Date: Wed, 15 Jun 2016 21:36:37 +0800
Message-ID: <1465997798-3261-1-git-send-email-zyjzyj2000@gmail.com>
References: <F6FB0E698C9B3143BDF729DF2228664696AC171C@ORSMSX116.amr.corp.intel.com>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	donald.c.skidmore@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [111.193.78.174] ([111.193.78.174]:35792 "EHLO mail.zhuyj.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932893AbcFONp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 09:45:26 -0400
In-Reply-To: <F6FB0E698C9B3143BDF729DF2228664696AC171C@ORSMSX116.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi, Don

The latest patch is based on your suggestion.
The changes are as below:

1. Replace IXGBE_IDENTIFIER with IXGBE_ESDP;
2. Replace plug interrupt with poll;
3. Indicate the NICs that does not support to plug/unplug tranceiver as plugged;

The patch can work well with the following steps:

 1. boot the host
 2. ip link set eth0 up
 3. unplug the fiber tranceiver
 4. a message NETDEV_FIBER_TRANCEIVER_UNPLUG is sent
 5. plug the fiber tranceiver
 6. a notifier NETDEV_FIBER_TRANCEIVER_PLUG is sent

Any reply is appreciated.

Zhu Yanun
