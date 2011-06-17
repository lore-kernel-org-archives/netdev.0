From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 001/001] vlan: don't call ndo_vlan_rx_register on
 hardware that doesn't have vlan support
Date: Fri, 17 Jun 2011 12:00:32 -0700
Message-ID: <20110617120032.6ed3ae3c@nehalam.ftrdhcpuser.net>
References: <BANLkTimBm8rFF41RzAN6vk3o6SLy6cfZDQ@mail.gmail.com>
	<20110617.001310.887138223551857478.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: a.reversat@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53927 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932325Ab1FQTAg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2011 15:00:36 -0400
In-Reply-To: <20110617.001310.887138223551857478.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Jun 2011 00:13:10 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Antoine Reversat <a.reversat@gmail.com>
> Date: Thu, 16 Jun 2011 16:47:13 -0400
> 
> > This patch removes the call to ndo_vlan_rx_register if the underlying
> > device doesn't have hardware support for VLAN.
> > Signed-off-by: Antoine Reversat <a.reversat@gmail.com>
> 
> Applied, thanks.

Need same check for unregister?
