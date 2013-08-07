From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ip_tunnel: embed hash list head
Date: Wed, 07 Aug 2013 16:48:29 -0700 (PDT)
Message-ID: <20130807.164829.2205016964525151029.davem@davemloft.net>
References: <20130805225137.6c934d7f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51498 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651Ab3HGXnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 19:43:14 -0400
In-Reply-To: <20130805225137.6c934d7f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 5 Aug 2013 22:51:37 -0700

> The IP tunnel hash heads can be embedded in the per-net structure
> since it is a fixed size. Reduce the size so that the total structure
> fits in a page size. The original size was overly large, even NETDEV_HASHBITS
> is only 8 bits!
> 
> Also, add some white space for readability.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks.
