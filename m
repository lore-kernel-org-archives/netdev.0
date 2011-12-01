From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core: fix rollback handler in
 register_netdevice_notifier
Date: Wed, 30 Nov 2011 23:43:29 -0500 (EST)
Message-ID: <20111130.234329.51988978321225025.davem@davemloft.net>
References: <1322707070-9514-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752296Ab1LAEnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 23:43:31 -0500
In-Reply-To: <1322707070-9514-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu,  1 Dec 2011 10:37:50 +0800

> From: RongQing.Li <roy.qing.li@gmail.com>
> 
> Within nested statements, the break statement terminates only the
> do, for, switch, or while statement that immediately encloses it,
> So replace the break with goto.
> 
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>

Good catch, applied, thanks.
