From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] skbuff: Fix offset error in skb_reorder_vlan_header
Date: Tue, 15 Dec 2015 00:31:10 -0500 (EST)
Message-ID: <20151215.003110.982750236713410843.davem@davemloft.net>
References: <566ED772.8070600@6wind.com>
	<1450133050-24636-1-git-send-email-vyasevich@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com, kaber@trash.net
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38472 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbbLOFbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 00:31:11 -0500
In-Reply-To: <1450133050-24636-1-git-send-email-vyasevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Mon, 14 Dec 2015 17:44:10 -0500

> skb_reorder_vlan_header is called after the vlan header has
> been pulled.  As a result the offset of the begining of
> the mac header has been incrased by 4 bytes (VLAN_HLEN).
> When moving the mac addresses, include this incrase in
> the offset calcualation so that the mac addresses are
> copied correctly.
> 
> Fixes: a6e18ff1117 (vlan: Fix untag operations of stacked vlans with REORDER_HEADER off)
> CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> CC: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Vladislav Yasevich <vyasevich@gmail.com>

Applied and queued up for -stable, thanks Vlad.
