From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: fix array index in ip6_mc_add_src()
Date: Thu, 05 Apr 2012 00:01:23 -0400 (EDT)
Message-ID: <20120405.000123.696176558837733767.davem@davemloft.net>
References: <1333594024-24347-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52554 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817Ab2DEEB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 00:01:26 -0400
In-Reply-To: <1333594024-24347-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu,  5 Apr 2012 10:47:04 +0800

> From: RongQing.Li <roy.qing.li@gmail.com>
> 
> Convert array index from the loop bound to the loop index.
> 
> And remove the void type conversion to ip6_mc_del1_src() return 
> code, seem it is unnecessary, since ip6_mc_del1_src() does not 
> use __must_check similar attribute, no compiler will report the
> warning when it is removed.
> 
> v2: enrich the commit header
> 
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com> 

Applied and queued up for -stable, thank you.
