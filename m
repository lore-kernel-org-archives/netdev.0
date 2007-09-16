From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] small cleanup for fib rules
Date: Sun, 16 Sep 2007 15:46:01 -0700 (PDT)
Message-ID: <20070916.154601.45886120.davem@davemloft.net>
References: <20070914110647.GA7369@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org, devel@openvz.org,
	dev@openvz.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:46311
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753436AbXIPWqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 18:46:43 -0400
In-Reply-To: <20070914110647.GA7369@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Fri, 14 Sep 2007 15:06:47 +0400

> From: Denis V. Lunev <den@openvz.org>
> 
> This patch slightly cleanups FIB rules framework. rules_list as a pointer
> on struct fib_rules_ops is useless. It is always assigned with a static
> per/subsystem list in IPv4, IPv6 and DecNet.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> Acked-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>

I am convinced you namespace guys will eventually eliminate
every single global variable in the kernel :-)

Patch applied to net-2.6.24, thanks!
