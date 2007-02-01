From: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Subject: [RFC][PATCH][XFRM][0/5] extension for XFRM databases
Date: Thu, 01 Feb 2007 13:09:51 +0900
Message-ID: <20070201114339.E2BD.SHINTA@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Francis Dupont <Francis.Dupont@point6.net>,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	usagi-core@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sfc.wide.ad.jp ([203.178.142.146]:42392 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161184AbXBAEci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 23:32:38 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Let me issue a request for comments for the patch set developed by
the USAGI project.  The patch set aims to extend the XFRM framework
so that endpoint addresses in the XFRM databases, namely XFRM policy
and XFRM state can be dynamically updated according to a request from
user application.  This feature is required for Mobile IPv6 to follow
the security requirements specified in RFC3776.  More specifically,
the Mobile Node and Home Agent need to update the endpoint addresses
of the IPsec tunnel when the Mobile Node changes its attachment point
(Care-of Address) to the Internet.  The kernel also notifies userland
application via both Netlink and PF_KEY sockets so that user application
(e.g. IKE Daemon) could be informed of the updates appropriately.
More detailed information of motivation/rationale for this feature
can be found in the internet draft[1].

The patch set consists of following patches:

[1/5] [XFRM]: Extension to the XFRM framework for dynamic update of endpoint address(es)
[2/5] [XFRM]: User interface for handling XFRM_MSG_MIGRATE
[3/5] [XFRM]: CONFIG_XFRM_MIGRATE option
[4/5] [PFKEYV2]: Extension to the PF_KEYv2 framework for dynamic update of endpoint address(es)
[5/5] [PFKEYV2]: CONFIG_NET_KEY_MIGRATE option

Any comments/suggestions are appreciated.
Thank you very much.

[1]: http://www.ietf.org/internet-drafts/draft-sugimoto-mip6-pfkey-migrate-03.txt


Regards,
Shinta


