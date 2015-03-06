From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: ip_check_defrag should not assume that
 skb_network_offset is zero
Date: Thu, 05 Mar 2015 21:44:02 -0500 (EST)
Message-ID: <20150305.214402.2193386882481808720.davem@davemloft.net>
References: <1425540579-27464-1-git-send-email-al.drozdov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: al.drozdov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbbCFCoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 21:44:04 -0500
In-Reply-To: <1425540579-27464-1-git-send-email-al.drozdov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Drozdov <al.drozdov@gmail.com>
Date: Thu,  5 Mar 2015 10:29:39 +0300

> ip_check_defrag() may be used by af_packet to defragment outgoing packets.
> skb_network_offset() of af_packet's outgoing packets is not zero.
> 
> Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>

Applied, thanks.
