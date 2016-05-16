From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netlink: kill nla_put_u64()
Date: Mon, 16 May 2016 13:47:04 -0400 (EDT)
Message-ID: <20160516.134704.1454236893448895407.davem@davemloft.net>
References: <1463145940-5932-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754283AbcEPRrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 13:47:06 -0400
In-Reply-To: <1463145940-5932-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 13 May 2016 15:25:40 +0200

> This function is not used anymore. nla_put_u64_64bit() should be used
> instead.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> 
> I'm asking myself if it's better to rename nla_put_u64_64bit() to
> nla_put_u64(). Because there is a lot of users, the change will be
> huge, so I tend to say no.

Applied.
