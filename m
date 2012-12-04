From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip6mr: fix rtm_family of rtnl msg
Date: Tue, 04 Dec 2012 13:27:56 -0500 (EST)
Message-ID: <20121204.132756.940248739629200866.davem@davemloft.net>
References: <1354618909-15631-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53863 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762Ab2LDS16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 13:27:58 -0500
In-Reply-To: <1354618909-15631-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue,  4 Dec 2012 12:01:49 +0100

> We talk about IPv6, hence the family is RTNL_FAMILY_IP6MR!
> rtnl_register() is already called with RTNL_FAMILY_IP6MR.
> 
> The bug is here since the beginning of this function (commit 5b285cac3570).
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks.
