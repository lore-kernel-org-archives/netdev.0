From: David Miller <davem@davemloft.net>
Subject: Re: HW communication debugging interface - ideas?
Date: Sun, 01 Nov 2015 11:51:16 -0500 (EST)
Message-ID: <20151101.115116.620913426492186507.davem@davemloft.net>
References: <20150930135141.GF2098@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eladr@mellanox.com, idosch@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751641AbbKAQvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 11:51:18 -0500
In-Reply-To: <20150930135141.GF2098@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 30 Sep 2015 15:51:41 +0200

> 2) generic Netlink (genl) interface. Easy to put metadata in, including the
> device identificator (pci address). User then can use nlmon in order to
> be able to use wireshark to see the netlink messages.
> 
> Looks like 2) might be viable, well-defined, generic interface to carry
> this info. What do you think? Does this make sense?

Sorry for the late response.  I definitely prefer this netlink idea,
particularly for the metadata aspect.

Yes, the ethernet frames should "identify" the device, but I much more
like the idea of precisely having the geographic ID of the device (PCI
ID, whatever) available as metadata as well.
