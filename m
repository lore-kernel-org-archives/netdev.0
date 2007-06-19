From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [NET 00/02]: MACVLAN driver
Date: Tue, 19 Jun 2007 09:00:27 -0700
Message-ID: <20070619090027.3312f2cf@localhost.localdomain>
References: <20070619130825.26769.23059.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53087 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752144AbXFSQFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 12:05:36 -0400
In-Reply-To: <20070619130825.26769.23059.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Jun 2007 15:08:41 +0200 (MEST)
Patrick McHardy <kaber@trash.net> wrote:

> These patches add a rewritten version of Ben's macvlan driver, which
> allows to create virtual ethernet devices. The underlying device is
> put in promiscous mode and packets are demuxed based on MAC address.
> It behaves similar to bridge devices in that packets are visible on
> the real device before delivery to the macvlan driver. The driver
> supports all features of the underlying device except VLAN
> acceleration, this is currently very hard to support. I might look
> into this in the future.
> 
> The main downside of this driver is that it adds another hook in
> netif_receive_skb, unfortunately that is unavoidable. When not
> compiled in the hook vanishes of course.
> 
> Usage is simple:
> 
> # ip link add link eth0 type macvlan
> 
> Will create a macvlan0 device with a random MAC address on top of
> eth0. No iproute patches are required.
> 
> 
> Please apply, thanks.
> 

Looks good. I have some changes to allow devices with multiple MAC addresses
(never finished).  This device could use that.
-- 
Stephen Hemminger <shemminger@linux-foundation.org>
