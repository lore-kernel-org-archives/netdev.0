From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 0/3] netfilter: propagate routing and XFRM errors
Date: Fri,  5 Apr 2013 18:41:09 +0200
Message-ID: <1365180072-6182-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36903 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162103Ab3DEQl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 12:41:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches fix a long standing annoyance: netfilter will return
EPERM for all errors during rerouting or XFRM policy lookups.

These patches change {ip,ip6}_route_me_harder() and nf_xfrm_me_harder()
to return errno codes and use NF_DROP_ERR() to propagate those back
to userspace.

Please apply.
