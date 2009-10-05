From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fib table algorithm performance improvement
Date: Mon, 05 Oct 2009 00:11:45 -0700 (PDT)
Message-ID: <20091005.001145.57977420.davem@davemloft.net>
References: <20090920133536.1511a2ad@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54613
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752009AbZJEHLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 03:11:50 -0400
In-Reply-To: <20090920133536.1511a2ad@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sun, 20 Sep 2009 13:35:36 -0700

> The FIB algorithim for IPV4 is set at compile time, but kernel goes through
> the overhead of function call indirection at runtime. Save some
> cycles by turning the indirect calls to direct calls to either
> hash or trie code.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-next-2.6
