From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: protect protocols not handling ipv4 from v4 connection/bind attempts
Date: Wed, 22 Jan 2014 02:08:42 +0100
Message-ID: <20140122010842.GB20565@order.stressinduktion.org>
References: <20140120041639.GA27055@order.stressinduktion.org> <20140121.165941.1593478240200500821.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56723 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbaAVBIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 20:08:43 -0500
Content-Disposition: inline
In-Reply-To: <20140121.165941.1593478240200500821.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 21, 2014 at 04:59:41PM -0800, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Mon, 20 Jan 2014 05:16:39 +0100
> 
> > Some ipv6 protocols cannot handle ipv4 addresses, so we must not allow
> > connecting and binding to them. sendmsg logic does already check msg->name
> > for this but must trust already connected sockets which could be set up
> > for connection to ipv4 address family.
> > 
> > Per-socket flag ipv6only is of no use here, as it is under users control
> > by setsockopt.
> > 
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> Applied.  Is the plan to add support to at least ping?

Yes, this is planned but for the meantime we should disable it.

Thanks!
