From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [RFC net-next 00/11] firewire net: resource management
 improvements
Date: Wed, 13 Mar 2013 15:19:19 +0100
Message-ID: <20130313151919.68068bae@stein>
References: <5139419A.2040309@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:48480 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933188Ab3CMOTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 10:19:40 -0400
In-Reply-To: <5139419A.2040309@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mar 08 YOSHIFUJI Hideaki wrote:
> This series of patches tries to improve resource management of IP over Firewire
> device.
> 
> Because upcoming IPv6 over Firewire patch depends on this series, it would
> be better to let this series of patches go through Dave's net-next tree, if
> firewire people do not mind.
> 
> --yoshfuji
> 
> YOSHIFUJI Hideaki (11):
>   firewire net: No need to reset dev->local_fifo after failure of
>     fw_core_add_address_handler().
>   firewire net: Introduce fwnet_fifo_{start,stop}() helpers.
>   firewire net: Setup broadcast and local fifo independently.
>   firewire net: Check dev->broadcast_state inside
>     fwnet_broadcast_start().
>   firewire net: Fix memory leakage in fwnet_remove().
>   firewire net: Clear dev->broadcast_rcv_context and
>     dev->broadcast_state after destruction of context.
>   firewire net: Omit checking dev->broadcast_rcv_context in
>     fwnet_broadcast_start().
>   firewire net: Fix leakage of kmap for broadcast receive buffer.
>   firewire net: Allocate dev->broadcast_rcv_buffer_ptrs early.
>   firewire net: Introduce fwnet_broadcast_stop() to destroy broadcast
>     resources.
>   firewire net: Release broadcast/fifo resources on ifdown.
> 
>  drivers/firewire/net.c |  177 ++++++++++++++++++++++++++++--------------------
>  1 file changed, 105 insertions(+), 72 deletions(-)
> 

All 11 patches:
Reviewed-by: Stefan Richter <stefanr@s5r6.in-berlin.de>

ACK for routing this through net-next.  David, do you need me to respond to
each individual patch with the reviewer tag?  Or since I already have the
patches in a quilt series locally, I could commit them to a branch at
linux1394.git and send you a pull request.
-- 
Stefan Richter
-=====-===-= --== -==-=
http://arcgraph.de/sr/
