From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net-2.6.24: wrap netdevice hardware header creation
Date: Wed, 26 Sep 2007 22:13:06 -0700 (PDT)
Message-ID: <20070926.221306.45074306.davem@davemloft.net>
References: <20070824204310.388073598@linux-foundation.org>
	<20070925.192428.18597166.davem@davemloft.net>
	<20070926172129.5550a636@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50079
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751924AbXI0FNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 01:13:08 -0400
In-Reply-To: <20070926172129.5550a636@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 26 Sep 2007 17:21:29 -0700

> 
> Add inline for common usage of hardware header creation, and
> fix bug in IPV6 mcast where the assumption about negative return is
> an errno. Negative return from hard_header means not enough space
> was available,(ie -N bytes).
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied.
