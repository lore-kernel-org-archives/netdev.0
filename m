From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix for ip_options_rcv_srr() daddr update.
Date: Tue, 15 Nov 2011 02:28:35 -0500 (EST)
Message-ID: <20111115.022835.551127337110017182.davem@davemloft.net>
References: <4EC1FB5D.80705@cn.fujitsu.com>
	<20111115.013527.2095109012737872896.davem@davemloft.net>
	<4EC21427.9080008@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40012 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753047Ab1KOH2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 02:28:41 -0500
In-Reply-To: <4EC21427.9080008@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Tue, 15 Nov 2011 15:26:31 +0800

> My question, in ip_forward() and ip_forward_options() rt is there, why not
> we just use it?

Because I'm trying to eliminate all accesses to rt->rt_dst because
when I remove the routing cache, routes will be shared.  One 'rt'
will refer to many specific destination addresses.
