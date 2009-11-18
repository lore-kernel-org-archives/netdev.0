From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v2] allow access to sysfs_groups member
Date: Wed, 18 Nov 2009 13:08:59 -0800 (PST)
Message-ID: <20091118.130859.99831401.davem@davemloft.net>
References: <20091118164126.GF325@e-circ.dyndns.org>
	<20091118.095716.61189059.davem@davemloft.net>
	<20091118205952.GB282@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: kurt.van.dijck@eia.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48579
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757944AbZKRVIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 16:08:42 -0500
In-Reply-To: <20091118205952.GB282@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Date: Wed, 18 Nov 2009 21:59:52 +0100

> This patch allows adding sysfs attribute groups during netdevice registration.
> The idea is that before the register_netdev call, several calls to
> netdev_sysfs_add_group can be done. These attributes are accessible (by
> udev) during the uevent.
> 
> Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Unfortunately, the code in this function is much different
in net-next-2.6 which is where I want to add this, and your
patch doesn't apply.

Please rebase your patch on that tree, thank you.
