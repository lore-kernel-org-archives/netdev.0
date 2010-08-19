From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tehuti: Use net_device_stats from struct net_device
Date: Thu, 19 Aug 2010 00:06:40 -0700 (PDT)
Message-ID: <20100819.000640.123990188.davem@davemloft.net>
References: <1282061577-19484-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: baum@tehutinetworks.net, andy@greyhouse.net,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52928
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751050Ab0HSHGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 03:06:22 -0400
In-Reply-To: <1282061577-19484-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 17 Aug 2010 18:12:57 +0200

> struct net_device has its own struct net_device_stats member, so use
> this one instead of a private copy in the bdx_priv struct.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Please delete the bdx_get_stats() function and the assignment of
it into the netdev ops, as it is now superfluous.

Thanks.
