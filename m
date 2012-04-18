From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: clean up rt6_clean_expires
Date: Tue, 17 Apr 2012 22:32:42 -0400 (EDT)
Message-ID: <20120417.223242.1496923668766692823.davem@davemloft.net>
References: <1333707190-14075-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20120413.125851.894792528374368454.davem@davemloft.net>
	<20120416133541.GC18159@midget.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gaofeng@cn.fujitsu.com, netdev@vger.kernel.org
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32866 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792Ab2DRCdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 22:33:52 -0400
In-Reply-To: <20120416133541.GC18159@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Mon, 16 Apr 2012 15:35:41 +0200

> Functionally, this change is a NOP.
> 
> Semantically, rt6_clean_expires() wants to do rt->dst.from = NULL instead of
> rt->dst.expires = 0. It is clearing the RTF_EXPIRES flag, so the union is going
> to be treated as a pointer (dst.from) not a long (dst.expires).
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>

Applied.
