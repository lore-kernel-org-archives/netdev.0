From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6:Fix the return value of Set Hop-by-Hop options
 header with NULL data pointer
Date: Sun, 03 Aug 2008 18:16:33 -0700 (PDT)
Message-ID: <20080803.181633.18908318.davem@davemloft.net>
References: <488D3563.9080607@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yanghy@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52523
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752030AbYHDBQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 21:16:33 -0400
In-Reply-To: <488D3563.9080607@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Hongyang <yanghy@cn.fujitsu.com>
Date: Mon, 28 Jul 2008 10:56:35 +0800

> When Set Hop-by-Hop options header with NULL data 
> pointer and optlen is not zero use setsockopt(),
> the kernel successfully return 0 instead of 
> return error EINVAL or EFAULT.
> 
> This patch fix the problem.
> 
> Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

Applied, thanks!
