From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ping: prevent NULL pointer dereference on write to msg_name
Date: Mon, 18 Nov 2013 23:15:42 +0100
Message-ID: <20131118221542.GN16541@order.stressinduktion.org>
References: <20131118060745.GL16541@order.stressinduktion.org> <20131118.160238.2288108703856396394.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51159 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374Ab3KRWPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 17:15:44 -0500
Content-Disposition: inline
In-Reply-To: <20131118.160238.2288108703856396394.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 18, 2013 at 04:02:38PM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Mon, 18 Nov 2013 07:07:45 +0100
> 
> > A plain read() on a socket does set msg->msg_name to NULL. So check for
> > NULL pointer first.
> > 
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> > 
> > Addendum to "[v4] inet: prevent leakage of uninitialized memory to user in
> > recv syscalls".
> 
> Applied and queued up for -stable, thanks Hannes.
> 
> Looks like ipv6 got this case right.

No, IPv6 reuses the IPv4 recvmsg handler. The patch fixes that as well.

Thanks,

  Hannes
