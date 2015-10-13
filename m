From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 11/17] i40e: Add promiscuous on VLAN support
Date: Tue, 13 Oct 2015 04:14:08 -0700 (PDT)
Message-ID: <20151013.041408.880270217805854932.davem@davemloft.net>
References: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1444715598-20970-12-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.v.rose@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753062AbbJMK6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 06:58:11 -0400
In-Reply-To: <1444715598-20970-12-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 12 Oct 2015 22:53:12 -0700

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> NFV use cases require the ability to steer packets to VSIs by VLAN tag
> alone while being in promiscuous mode for multicast and unicast MAC
> addresses.  These two new functions support that ability.
> 
> Change-ID: Ifef704b07e0ee8a39d3c351dbd5dc83bb2f63c45
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Nothing in the driver calls these functions.

Please do not add code or defines or facilities that are
completely unused in the upstream driver.

Thanks.
