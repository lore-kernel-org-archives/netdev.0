From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next]: net: remove ifalias on empty given alias
Date: Tue, 23 Sep 2008 21:23:35 -0700 (PDT)
Message-ID: <20080923.212335.122243864.davem@davemloft.net>
References: <20080922174346.2ad15d26@extreme>
	<48D948E8.6090804@hartkopp.net>
	<20080923131452.5d40dd03@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@hartkopp.net, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51444
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750768AbYIXEXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 00:23:47 -0400
In-Reply-To: <20080923131452.5d40dd03@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 23 Sep 2008 13:14:52 -0700

> On Tue, 23 Sep 2008 21:52:08 +0200
> Oliver Hartkopp <oliver@hartkopp.net> wrote:
> 
> > This patch removes the potentially allocated ifalias when the (new) 
> > given alias is empty.
> > 
> > E.g. when setting
> > 
> > echo "" > /sys/class/net/eth0/ifalias
> > 
> > Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
> > ---
> > 
> > Hello Stephen,
> > 
> > this patch allows to 'remove' or reset the ifalias by giving an empty alias.
> > The patch is tested.
> > Btw. ifalias is a nice idea also for CAN bus people to 'name' a given 
> > CAN bus.
> > 
> > Thanks & regards,
> > Oliver
> > 
> > 
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Also, udev could put a default value in based on the slot information it has.

I've applied Oliver's patch.
