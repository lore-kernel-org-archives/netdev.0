From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch net-next 5/5] mac80211: fix checkpatch error
Date: Wed, 18 Dec 2013 10:05:48 +0100
Message-ID: <1387357548.4694.0.camel@jlt4.sipsolutions.net>
References: <1387352656-860-1-git-send-email-chenweilong@huawei.com>
	 <1387352656-860-6-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linville@tuxdriver.com, netdev@vger.kernel.org
To: Chen Weilong <chenweilong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:48752 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910Ab3LRJGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 04:06:08 -0500
In-Reply-To: <1387352656-860-6-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-18 at 15:44 +0800, Chen Weilong wrote:

>  #define for_each_sta_info(local, _addr, _sta, nxt)			\
> -	for (	/* initialise loop */					\
> +	for (/* initialise loop */					\
>  		_sta = rcu_dereference(local->sta_hash[STA_HASH(_addr)]),\
>  		nxt = _sta ? rcu_dereference(_sta->hnext) : NULL;	\
>  		/* typecheck */						\

I've applied it all (I squashed it though, no sense in having 5 small
commits that look identical on first glance), except for this bit - the
code here is aligned that way on purpose.

johannes
