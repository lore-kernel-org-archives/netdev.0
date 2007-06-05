From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: Fwd: dma_skb_copy_datagram_iovec not EXPORTed
Date: Tue, 5 Jun 2007 10:24:27 -0700
Message-ID: <20070605102427.26dd7fac.randy.dunlap@oracle.com>
References: <908954150706041006v2a429726yd267c06ab42a1107@mail.gmail.com>
	<908954150706050756x2c7fbee0o9b9df550a09bffb7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, christopher.leech@intel.com
To: "Sam Hopkins" <s.a.hopkins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:36459 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127AbXFERZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 13:25:40 -0400
In-Reply-To: <908954150706050756x2c7fbee0o9b9df550a09bffb7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 5 Jun 2007 10:56:58 -0400 Sam Hopkins wrote:

> Hello,
> 
> I'm forwarding along a message sent to kernelnewbies as I was directed
> to address my question to this list.  I am not a member of netdev, so
> please copy me on all discussion of this topic.
> 
> Cheers,
> 
> Sam
> 
> ---
> 
> Greetings,
> 
> I am a developer of the kernel AoE (ATA over Ethernet) driver.  I am
> attempting to add dma offloading of data receive, following in TCP's
> footsteps via config option NET_DMA.  There is a function in
> net/core/user_dma.c, dma_skb_copy_datagram_iovec, that appears to be
> exactly what I need, but this function is not EXPORTed for use by
> external modules.
> 
> Since the NET_DMA option is documented as "Network: TCP receive copy
> offload" perhaps it's just an oversight that anyone else might benefit
> from it?

Makes sense to me.  Maybe someone in the hierarchy will agree,
or you may need to just send a patch and see if it is accepted.


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
