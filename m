From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 4/4] neigh: don't leak default parms to uninitial
 netns
Date: Wed, 19 Jun 2013 18:05:05 -0700 (PDT)
Message-ID: <20130619.180505.1958820391321832484.davem@davemloft.net>
References: <1371175607-1405-1-git-send-email-gaofeng@cn.fujitsu.com>
	<1371175607-1405-4-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46851 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934734Ab3FTBFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 21:05:06 -0400
In-Reply-To: <1371175607-1405-4-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Fri, 14 Jun 2013 10:06:47 +0800

> Only allow initial net namespace to get default parms
> through netlink.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Disallowing changes to the default neigh parms is fine, but there is no
reason to forbid seeing what default neigh parms will be used in a given
network namespace just because it isn't &init_net.

I don't see why you want to restrict this at all.

I'm not applying these patches, sorry.
