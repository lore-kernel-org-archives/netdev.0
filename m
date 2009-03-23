From: David Miller <davem@davemloft.net>
Subject: rndis_wlan netdev ops
Date: Mon, 23 Mar 2009 13:43:18 -0700 (PDT)
Message-ID: <20090323.134318.106371116.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38032
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754771AbZCWUna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 16:43:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is the only driver that won't build for me with
the netdev ops compat option disabled.

It's trying to override the ->set_mutlicast_list op value
of it's parent device.

Did you hit this one and I just missed it or is it not handled
yet?

Probably what we'll have to do for this case is allocate a
netdev_ops copy so that the ->set_multicast_list can be set
to a new value.  But that defeats the whole purpose of netdev
ops so I assume you have other plans :-)
