From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: use helpers to access uc list
Date: Mon, 25 Jan 2010 02:06:28 -0800 (PST)
Message-ID: <20100125.020628.124583614.davem@davemloft.net>
References: <20100124104239.GA21371@psychotron.redhat.com>
	<20100124.230251.177086043.davem@davemloft.net>
	<20100125083450.GA2902@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54335
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753120Ab0AYKGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 05:06:17 -0500
In-Reply-To: <20100125083450.GA2902@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Mon, 25 Jan 2010 09:34:52 +0100

> Well I use "unsigned char *" as iterator because it would allow
> smooth thansition to list_head in case of mc_list. Currently "struct
> dev_addr_list" is used to store address in the list but in the end
> "struct netdev_hw_addr *" will be used.  To use "struct list_head *"
> or "struct netdev_hw_addr *" as an iterator it would be needed to
> convert all drivers at once and that's not doable. Therefore I see
> "unsigned char *" cursor as the best option.

But it's not what you want to use in the end, at all.

If you're going to use a very ugly and opaque iterator type merely to
ease transition, that's not a good reason.
