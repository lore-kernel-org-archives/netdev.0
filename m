From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bug[#43]: kgdboe: netpoll: Should handle ETH_P_ARP
 other than ETH_P_IP in netpoll_neigh_reply
Date: Thu, 12 Sep 2013 17:17:49 -0400 (EDT)
Message-ID: <20130912.171749.1115925798910466790.davem@davemloft.net>
References: <1378870313-14161-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net,
	sonic.zhang@analog.com, amwang@redhat.com
To: sonic.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38711 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755466Ab3ILVRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 17:17:51 -0400
In-Reply-To: <1378870313-14161-1-git-send-email-sonic.adi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.adi@gmail.com>
Date: Wed, 11 Sep 2013 11:31:53 +0800

> From: Sonic Zhang <sonic.zhang@analog.com>
> 
> The received ARP request type in the Ethernet packet head is ETH_P_ARP other than ETH_P_IP.
> 
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>

This bug was introduced by commit b7394d2429c198b1da3d46ac39192e891029ec0f
("netpoll: prepare for ipv6")

I'll apply this, thank you.
