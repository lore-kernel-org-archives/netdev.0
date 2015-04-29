From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] netlink: fix wrong use of the flag NLM_F_MULTI
Date: Wed, 29 Apr 2015 15:00:15 -0400 (EDT)
Message-ID: <20150429.150015.854202938628093066.davem@davemloft.net>
References: <1430238831-29966-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dmitry.tarnyaginuug.ch@6wind.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50197 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961AbbD2TAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 15:00:18 -0400
In-Reply-To: <1430238831-29966-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 28 Apr 2015 18:33:47 +0200

> The first three patches fix a wrong use of this flag.
> 
> Because it's not the first time that this kind of bug happens, it could be
> good to find something to help people.
> 
> The only idea that I have is in the last patch. It's just an example, if
> people agrees on it, I will update all users and submit it formally.
> Any better idea is welcomed.

I've applied this series.

The only thing with patch #4 is that we have to make sure everyone
initializes all fields.  It would be nice if there were a way to
sort-of enforce that.

Even just having a static inline initializer helper func might be
enough, like I added for nf_hook_info.
