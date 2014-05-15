From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] rtnetlink: wait for unregistering devices in
 rtnl_link_unregister()
Date: Thu, 15 May 2014 14:32:42 -0400 (EDT)
Message-ID: <20140515.143242.2060472577881743700.davem@davemloft.net>
References: <1399932680-31479-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	cwang@twopensource.com, ebiederm@xmission.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35033 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755677AbaEOSco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 14:32:44 -0400
In-Reply-To: <1399932680-31479-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 12 May 2014 15:11:20 -0700

> +static void rtnl_lock_unregistering_all(void)

This is just:

	rtnl_lock_unregistering(&net_namespace_list);

There is no need to reimplement the entire thing.
