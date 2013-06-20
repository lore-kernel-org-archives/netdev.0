From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 RESEND 1/3] neigh: no need to call
 lookup_neigh_parms in neigh_parms_alloc
Date: Wed, 19 Jun 2013 21:13:42 -0700 (PDT)
Message-ID: <20130619.211342.2004923326709314979.davem@davemloft.net>
References: <1371693694-18531-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48550 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711Ab3FTENm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 00:13:42 -0400
In-Reply-To: <1371693694-18531-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Thu, 20 Jun 2013 10:01:32 +0800

> neigh_table.parms always exist and is initialized,kmemdup
> can use it to create new neigh_parms, actually lookup_neigh_parms
> here will return neigh_table.parms too.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Applied.
