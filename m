From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] ipv6: convert addrconf list to hlist
Date: Sat, 20 Mar 2010 16:05:30 -0700 (PDT)
Message-ID: <20100320.160530.233672252.davem@davemloft.net>
References: <20100318063108.109693694@vyatta.com>
	<20100318063122.935061603@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45310
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752615Ab0CTXFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 19:05:08 -0400
In-Reply-To: <20100318063122.935061603@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 17 Mar 2010 23:31:10 -0700

> Using hash list macros, simplifies code and helps later RCU.
> 
> This patch includes some initialization that is not strictly necessary,
> since an empty hlist node/list is all zero; and list is in BSS
> and node is allocated with kzalloc.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
