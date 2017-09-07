From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: access nlk groups safely in netlink bind
 and getname
Date: Wed, 06 Sep 2017 21:24:25 -0700 (PDT)
Message-ID: <20170906.212425.1399303829278739542.davem@davemloft.net>
References: <cfb5c05d158b278beb2f1441c67a068a8bb27d44.1504670009.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46654 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752525AbdIGEY0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 00:24:26 -0400
In-Reply-To: <cfb5c05d158b278beb2f1441c67a068a8bb27d44.1504670009.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Wed,  6 Sep 2017 11:53:29 +0800

> Now there is no lock protecting nlk ngroups/groups' accessing in
> netlink bind and getname. It's safe from nlk groups' setting in
> netlink_release, but not from netlink_realloc_groups called by
> netlink_setsockopt.
> 
> netlink_lock_table is needed in both netlink bind and getname when
> accessing nlk groups.
> 
> Acked-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
