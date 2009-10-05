From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] bonding: allow previous slave to be used when
 re-balancing traffic on tlb/alb interfaces
Date: Mon, 05 Oct 2009 03:43:33 -0700 (PDT)
Message-ID: <20091005.034333.04801045.davem@davemloft.net>
References: <1254269731-7341-1-git-send-email-fubar@us.ibm.com>
	<1254269731-7341-2-git-send-email-fubar@us.ibm.com>
	<8075.1254532437@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43567
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932518AbZJEKni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 06:43:38 -0400
In-Reply-To: <8075.1254532437@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 02 Oct 2009 18:13:57 -0700

> 	Andy, I've been doing some further testing with this patch, and
> I'm seeing some panics that I believe are related to this patch.  It
> appears that the last_slave isn't cleared (or isn't cleared soon enough)
> when a slave is released, and concurrent transmit activity is getting
> into alb_get_best_slave() and finding a last_slave pointer that is stale
> (points to no slave currently on the slave list).

I'm holding off on these 3 bonding patches until this is resolved.
