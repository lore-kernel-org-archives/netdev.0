From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v7] net: dummy: Introduce dummy virtual
 functions
Date: Tue, 24 Jan 2017 14:07:42 -0500 (EST)
Message-ID: <20170124.140742.2012452984177351042.davem@davemloft.net>
References: <20170123111733.28643-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sd@queasysnail.net
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55594 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750860AbdAXTHo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 14:07:44 -0500
In-Reply-To: <20170123111733.28643-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Mon, 23 Jan 2017 12:17:33 +0100

> The idea for this was born when testing VF support in iproute2 which was
> impeded by hardware requirements. In fact, not every VF-capable hardware
> driver implements all netdev ops, so testing the interface is still hard
> to do even with a well-sorted hardware shelf.
> 
> To overcome this and allow for testing the user-kernel interface, this
> patch allows to turn dummy into a PF with a configurable amount of VFs.
> 
> Since my patch series 'bus-agnostic-num-vf' has been accepted,
> implementing the required interfaces is pretty straightforward: Iff
> 'num_vfs' module parameter was given a value >0, a dummy bus type is
> being registered which implements the 'num_vf()' callback. Additionally,
> a dummy parent device common to all dummy devices is registered which
> sits on the above dummy bus.
> 
> Joint work with Sabrina Dubroca.
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Yeah this looks awesome, applied, thanks!
