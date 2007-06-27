From: David Miller <davem@davemloft.net>
Subject: Re: [NET 04/05]: dev: secondary unicast address support
Date: Wed, 27 Jun 2007 01:28:40 -0700 (PDT)
Message-ID: <20070627.012840.98863737.davem@davemloft.net>
References: <20070622122330.15215.47821.sendpatchset@localhost.localdomain>
	<20070622122336.15215.95560.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42609
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752655AbXF0I2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 04:28:20 -0400
In-Reply-To: <20070622122336.15215.95560.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 22 Jun 2007 14:24:12 +0200 (MEST)

> [NET]: dev: secondary unicast address support
> 
> Add support for configuring secondary unicast addresses on network
> devices. To support this devices capable of filtering multiple
> unicast addresses need to change their set_multicast_list function
> to configure unicast filters as well and assign it to dev->set_rx_mode
> instead of dev->set_multicast_list. Other devices are put into promiscous
> mode when secondary unicast addresses are present.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Also applied, thanks for doing this work Patrick.

I'll let the driver maintainers approve and merge individual
device support.

Thanks again.
