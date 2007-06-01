From: David Miller <davem@davemloft.net>
Subject: Re: ETHTOOL_GSET IOCTL on GigE links
Date: Fri, 01 Jun 2007 15:59:29 -0700 (PDT)
Message-ID: <20070601.155929.52113315.davem@davemloft.net>
References: <4660A044.5090007@garzik.org>
	<46F9780F64AE9945815725F4C0C72CB80302625D@hq-exch-1.corp.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, linux-net@vger.kernel.org, netdev@vger.kernel.org
To: jharan@Brocade.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39891
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753365AbXFAW7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 18:59:16 -0400
In-Reply-To: <46F9780F64AE9945815725F4C0C72CB80302625D@hq-exch-1.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jeff Haran" <jharan@Brocade.COM>
Date: Fri, 1 Jun 2007 15:51:18 -0700

> OK, but my question remains. In the case where a device supports one set
> of speeds via autonegotiation and another set via forcing, how does one
> tell which speeds can be forced and which can be autonegotiated?

Unfortunately, as you have noted, this information is not
given at the moment.

I got bit by this the other week when I wanted to try forcing
gigabit on a tg3 and the driver wouldn't allow it because it
only allows forcing link speeds at 10/100 on copper links.
