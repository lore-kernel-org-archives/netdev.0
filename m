From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: Use proper endian type for vni in
 vxlan[6]_xmit_skb
Date: Sun, 26 Jul 2015 16:33:51 -0700 (PDT)
Message-ID: <20150726.163351.1709485504402821647.davem@davemloft.net>
References: <43ce50f9da21ebe190cfd6d41b334978250c061d.1437576553.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755092AbbGZXdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 19:33:52 -0400
In-Reply-To: <43ce50f9da21ebe190cfd6d41b334978250c061d.1437576553.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 22 Jul 2015 17:08:42 +0200

> Silences the following sparse warnings:
> drivers/net/vxlan.c:1818:21: warning: incorrect type in assignment (different base types)
> drivers/net/vxlan.c:1818:21:    expected restricted __be32 [usertype] vx_vni
> drivers/net/vxlan.c:1818:21:    got unsigned int [unsigned] [usertype] vni
> drivers/net/vxlan.c:2014:58: warning: incorrect type in argument 11 (different base types)
> drivers/net/vxlan.c:2014:58:    expected unsigned int [unsigned] [usertype] vni
> drivers/net/vxlan.c:2014:58:    got restricted __be32 [usertype] <noident>
> 
> Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks.
