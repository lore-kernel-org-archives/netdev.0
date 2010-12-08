From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] X.25: decrement netdev reference counts on unload
Date: Wed, 08 Dec 2010 10:55:02 -0800 (PST)
Message-ID: <20101208.105502.70203613.davem@davemloft.net>
References: <20101207194330.GA22608@noc.grnet.gr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: apollon@noc.grnet.gr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47684
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755125Ab0LHSyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 13:54:35 -0500
In-Reply-To: <20101207194330.GA22608@noc.grnet.gr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Apollon Oikonomopoulos <apollon@noc.grnet.gr>
Date: Tue, 7 Dec 2010 21:43:30 +0200

> x25 does not decrement the network device reference counts on module unload.
> Thus unregistering any pre-existing interface after unloading the x25 module
> hangs and results in
> 
>  unregister_netdevice: waiting for tap0 to become free. Usage count = 1
> 
> This patch decrements the reference counts of all interfaces in x25_link_free,
> the way it is already done in x25_link_device_down for NETDEV_DOWN events.
> 
> Signed-off-by: Apollon Oikonomopoulos <apollon@noc.grnet.gr>

Applied and queued up for -stable, thanks.
