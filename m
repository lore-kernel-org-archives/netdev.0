From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gre/ipip: use be16 variants of netlink
 functions
Date: Sun, 08 Feb 2015 16:28:57 -0800 (PST)
Message-ID: <20150208.162857.312338719028302352.davem@davemloft.net>
References: <1423239742-30865-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34381 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693AbbBIA3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 19:29:00 -0500
In-Reply-To: <1423239742-30865-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Fri,  6 Feb 2015 17:22:22 +0100

> encap.sport and encap.dport are __be16, use nla_{get,put}_be16 instead
> of nla_{get,put}_u16.
> 
> Fixes the sparse warnings:
 ...
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied.
