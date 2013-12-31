From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: shouldn't dump the expired routes
Date: Tue, 31 Dec 2013 16:01:40 -0500 (EST)
Message-ID: <20131231.160140.1452220526965978659.davem@davemloft.net>
References: <52BBC5F9.4050904@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36266 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756546Ab3LaVBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 16:01:42 -0500
In-Reply-To: <52BBC5F9.4050904@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Thu, 26 Dec 2013 14:00:25 +0800

> If we execute the command "ip -6 route show table all", those routes
> that have been expired will be dumped.  But as everyone knows, those
> expired routes will not be used, and they will be deleted by the kernel.
> So why we still need to dump they, and just don't dump them.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

I totally disagree with this change.

These routes are absolutely not guarenteed to never be used, their
inapplicability is temporary.

A router info advertisement can undo the expiration on an existing
route, so such ipv6 routes can become valid again.  Seeing them in
the route dump is therefore very useful.

I'm not applying this, sorry.
