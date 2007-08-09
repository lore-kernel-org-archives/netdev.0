From: David Miller <davem@davemloft.net>
Subject: Re: [NEIGH]: Netlink notifications
Date: Wed, 08 Aug 2007 23:13:48 -0700 (PDT)
Message-ID: <20070808.231348.105422682.davem@davemloft.net>
References: <20070731211235.GI9285@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55934
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S935062AbXHIGNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 02:13:53 -0400
In-Reply-To: <20070731211235.GI9285@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 31 Jul 2007 23:12:35 +0200

> Currently neighbour event notifications are limited to update
> notifications and only sent if the ARP daemon is enabled. This
> patch extends the existing notification code by also reporting
> neighbours being removed due to gc or administratively and
> removes the dependency on the ARP daemon. This allows to keep
> track of neighbour states without periodically fetching the
> complete neighbour table.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Also applied to net-2.6.24, thanks!
