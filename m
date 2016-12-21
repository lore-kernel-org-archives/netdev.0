From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net: dummy: Introduce dummy virtual functions
Date: Wed, 21 Dec 2016 13:32:00 -0500 (EST)
Message-ID: <20161221.133200.173665554896949124.davem@davemloft.net>
References: <20161220222621.32493-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sd@queasysnail.net
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33814 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935667AbcLUScC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 13:32:02 -0500
In-Reply-To: <20161220222621.32493-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Tue, 20 Dec 2016 23:26:21 +0100

> The idea for this was born when testing VF support in iproute2 which was
> impeded by hardware requirements. In fact, not every VF-capable hardware
> driver implements all netdev ops, so testing the interface is still hard
> to do even with a well-sorted hardware shelf.
> 
> To overcome this and allow for testing the user-kernel interface, this
> patch allows to turn dummy into a PF with a configurable amount of VFs.
> 
> Due to the assumption that all PFs are PCI devices, this implementation
> is not completely straightforward: In order to allow for
> rtnl_fill_ifinfo() to see the dummy VFs, a fake PCI parent device is
> attached to the dummy netdev. This has to happen at the right spot so
> register_netdevice() does not get confused. This patch abuses
> ndo_fix_features callback for that. In ndo_uninit callback, the fake
> parent is removed again for the same purpose.
> 
> Joint work with Sabrina Dubroca.
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Please resubmit when net-next opens back up, thanks.
