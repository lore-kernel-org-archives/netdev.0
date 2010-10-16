From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: cleanup function namespace
Date: Sat, 16 Oct 2010 11:56:56 -0700 (PDT)
Message-ID: <20101016.115656.246518839.davem@davemloft.net>
References: <4CB5E79B.4060507@windriver.com>
	<20101013.142834.226768662.davem@davemloft.net>
	<20101013162035.0c2e8123@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, allan.stephens@windriver.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35274
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753565Ab0JPS4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 14:56:34 -0400
In-Reply-To: <20101013162035.0c2e8123@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 13 Oct 2010 16:20:35 -0700

> Do some cleanups of TIPC based on make namespacecheck
>   1. Don't export unused symbols
>   2. Eliminate dead code
>   3. Make functions and variables local
>   4. Rename buf_acquire to tipc_buf_acquire since it is used in several files
> 
> Compile tested only.
> This make break out of tree kernel modules that depend on TIPC routines.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I really think we can and should do this now, so I've
applied this to net-next-2.6

Thanks everyone.
