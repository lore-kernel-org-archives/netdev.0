From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 0/44] Mobile IPv6 Platform, Take 2 (for net-2.6.19)
Date: Thu, 24 Aug 2006 00:02:01 +0900
Message-ID: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:56200 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964915AbWHWPCt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:49 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

This is the update of the "MIPv6 CN introduction" and "MIPv6 CN"
based on the MIPL2 kernel patch.

Major difference from the last reviewed patches are:

 o Updates from netdev comments
   - Remove CONFIG_XFRM_ADVANCED
   - Make more inline functions for readability
   - Reorder patch by the point of not files but features
   - Use new netlink attribute message type instead of changing
     public structure for user-space

 o New patch
   - [PATCH 16/44] [XFRM] IPV6: Restrict bundle reusing

Transformation mode is used like IPsec transport or tunnel.
It is required to add two more items, route optimization and
inbound trigger for Mobile IPv6.

It is also available at:
	git://git.skbuff.net/gitroot/yoshfuji/net-2.6.19-20060821-mip6cn-20060823

P.S.

we have another discussion about improvement of XFRM state hash.
Our patches (about source address list part) will conflict with that
work, but we did not take that into account so far because it was not
in the tree.

