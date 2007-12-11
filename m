From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] NETLINK : kzalloc() conversion
Date: Mon, 10 Dec 2007 21:43:37 -0800 (PST)
Message-ID: <20071210.214337.86437493.yoshfuji@linux-ipv6.org>
References: <475E22C2.9050700@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:43474 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147AbXLKFnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 00:43:13 -0500
In-Reply-To: <475E22C2.9050700@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <475E22C2.9050700@cosmosbay.com> (at Tue, 11 Dec 2007 06:40:18 +0100), Eric Dumazet <dada1@cosmosbay.com> says:

> nl_pid_hash_alloc() is renamed to nl_pid_hash_zalloc().
> It is now returning zeroed memory to its callers.

I do think you do not need (and you should not) rename it
because XXX_zalloc() would imply we have raw XXX_alloc().

--yoshfuji

