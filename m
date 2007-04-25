From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] infinite recursion in netlink
Date: Wed, 25 Apr 2007 13:09:32 -0700 (PDT)
Message-ID: <20070425.130932.70219336.davem@davemloft.net>
References: <20070425183856.GA6028@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: security@kernel.org, greg@kroah.com, netdev@vger.kernel.org,
	jaco@kroon.co.za
To: kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34846
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2993052AbXDYUJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 16:09:24 -0400
In-Reply-To: <20070425183856.GA6028@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Wed, 25 Apr 2007 22:38:56 +0400

> Reply to NETLINK_FIB_LOOKUP messages were misrouted back to kernel,
> which resulted in infinite recursion and stack overflow.
> 
> The bug is present in all kernel versions since the feature appeared.
> 
> The patch also makes some minimal cleanup:
> 
> 1. Return something consistent (-ENOENT) when fib table is missing
> 2. Do not crash when queue is empty (does not happen, but yet)
> 3. Put result of lookup
> 
> Signed-off-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>

Applied, thanks a lot Alexey.
