From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] drivers/net/au1000_eth.c: Remove misuse of
 DECLARE_MAC_BUF
Date: Tue, 08 Dec 2009 20:42:49 -0800 (PST)
Message-ID: <20091208.204249.02307242.davem@davemloft.net>
References: <1260131563.11126.124.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38783
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755850AbZLIEmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 23:42:43 -0500
In-Reply-To: <1260131563.11126.124.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sun, 06 Dec 2009 12:32:43 -0800

> And use a directly declared buffer.
> 
> It's used in a call to prom_get_ethernet_addr to
> get a 6 byte address, not a formatted output string.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

This DECLARE_MAC_BUF reference is already moved in the tree.
