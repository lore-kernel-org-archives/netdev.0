From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvlan: Introduce 'passthru' mode to takeover the
 underlying device
Date: Mon, 22 Nov 2010 08:24:41 -0800 (PST)
Message-ID: <20101122.082441.71132032.davem@davemloft.net>
References: <1288307450.30131.82.camel@sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, kaber@trash.net, shemminger@vyatta.com,
	mst@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37181
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750980Ab0KVQYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 11:24:16 -0500
In-Reply-To: <1288307450.30131.82.camel@sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Thu, 28 Oct 2010 16:10:50 -0700

> With the current default 'vepa' mode, a KVM guest using virtio with 
> macvtap backend has the following limitations.
> - cannot change/add a mac address on the guest virtio-net
> - cannot create a vlan device on the guest virtio-net
> - cannot enable promiscuous mode on guest virtio-net
> 
> To address these limitations, this patch introduces a new mode called
> 'passthru' when creating a macvlan device which allows takeover of the
> underlying device and passing it to a guest using virtio with macvtap
> backend.
> 
> Only one macvlan device is allowed in passthru mode and it inherits
> the mac address from the underlying device and sets it in promiscuous 
> mode to receive and forward all the packets.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied, thanks Sridhar.
