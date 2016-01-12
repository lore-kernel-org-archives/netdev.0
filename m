From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] netlink: fix null pointer dereference on nlk->groups
Date: Tue, 12 Jan 2016 14:40:49 -0500 (EST)
Message-ID: <20160112.144049.336054136817784262.davem@davemloft.net>
References: <1452231970-27357-1-git-send-email-sploving1@gmail.com>
	<1452597043-4298-1-git-send-email-sploving1@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sploving1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53317 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774AbcALTku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 14:40:50 -0500
In-Reply-To: <1452597043-4298-1-git-send-email-sploving1@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baozeng Ding <sploving1@gmail.com>
Date: Tue, 12 Jan 2016 19:10:43 +0800

> If groups is not 0 and nlk->groups is NULL, it will not return
> immediately and cause a null pointer dereference later.
> 
> Signed-off-by: Baozeng Ding <sploving1@gmail.com>
> ---
> The v3 version adds WARN_ON, suggested by David Miller. Thanks for
> David's feedback.

My feedback was also that the situation is illegal, and therefore you
have to explain to us how this can actually occur.
