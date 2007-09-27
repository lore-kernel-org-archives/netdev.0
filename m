From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add network namespace clone & unshare support.
Date: Wed, 26 Sep 2007 22:04:50 -0700 (PDT)
Message-ID: <20070926.220450.08654654.davem@davemloft.net>
References: <m1tzphrnq5.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51139
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750919AbXI0FEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 01:04:50 -0400
In-Reply-To: <m1tzphrnq5.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 26 Sep 2007 17:49:54 -0600

> 
> This patch allows you to create a new network namespace
> using sys_clone, or sys_unshare.
> 
> As the network namespace is still experimental and under development
> clone and unshare support is only made available when CONFIG_NET_NS is
> selected at compile time.
> 
> As this patch introduces network namespace support into code paths
> that exist when the CONFIG_NET is not selected there are a few
> additions made to net_namespace.h to allow a few more functions
> to be used when the networking stack is not compiled in.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied to net-2.6.24, thanks Eric.
