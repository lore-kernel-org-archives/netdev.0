From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 NEXT 1/1] netxen: add vlan accel support
Date: Fri, 05 Aug 2011 03:26:06 -0700 (PDT)
Message-ID: <20110805.032606.1214964517719657458.davem@davemloft.net>
References: <1312536015-21719-2-git-send-email-amit.salecha@qlogic.com>
	<20110805.024247.1468547132343070339.davem@davemloft.net>
	<99737F4847ED0A48AECC9F4A1974A4B80FE464EF82@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	rajesh.borundia@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33509 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753196Ab1HEK0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 06:26:12 -0400
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80FE464EF82@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Salecha <amit.salecha@qlogic.com>
Date: Fri, 5 Aug 2011 05:12:37 -0500

> After fw recovery we don't get vlan devices by any kernel api, so we
> are adding NETIF_VLAN_ACC support.  Earlier kernel had vlan group
> support, through that we get vlan devices and then their ip
> addresses.

Every time an IP address is added or removed there is a notification
generated on the "inetaddr_chain", and you seem to be properly using
this.

You have the VLAN device expansion in there as well.

Why doesn't this work?

The IP addresses cannot be added or removed from the VLAN device
until it is attached to your device.  So you should see any IP
address manipulation that occurs for VLANs stacked on top of
your device.

