From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: sh_eth: fix skb_over_panic happen
Date: Tue, 07 Feb 2012 13:38:06 -0500 (EST)
Message-ID: <20120207.133806.473035154885048767.davem@davemloft.net>
References: <4F30F503.6090300@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	nobuhiro.iwamatsu.yj@renesas.com
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35560 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753706Ab2BGSiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 13:38:12 -0500
In-Reply-To: <4F30F503.6090300@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Date: Tue, 07 Feb 2012 18:55:15 +0900

> When this GETHER controller received a large frame (about 1800 bytes
> or more), skb_over_panic() happened. This is because the previous
> driver set the RFLR to 0x1000 (4096 bytes) and the skb allocate size
> is smaller than 4096 bytes. So, the controller accepted such a frame.
> 
> The controller can discard a large frame by the RFLR setting.
> So, the patch modifies the value of RFLR to mtu + ETH_HLEN +
> VLAN_HLEN + ETH_FCS_LEN.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
