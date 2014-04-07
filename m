From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] ipv6: Reparent temporary address(es) if global address was, deleted from userspace
Date: Mon, 7 Apr 2014 12:22:29 +0200
Message-ID: <20140407102229.GB27255@order.stressinduktion.org>
References: <53423AF0.5080308@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Heiner Kallweit <heiner.kallweit@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55414 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754636AbaDGKWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 06:22:31 -0400
Content-Disposition: inline
In-Reply-To: <53423AF0.5080308@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 07, 2014 at 07:43:12AM +0200, Heiner Kallweit wrote:
> If the kernel takes care of global and temporary addresses it can happen
> that the global address is deleted from userspace,
> e.g. by network managers in case the link goes (temporarily) down.
> In addition to the then orphaned temporary address(es) the next RA will
> create a new temporary address. Therefore we might end up with more than
> one non-deprecated temporary address for the same prefix for a longer
> period of time (>regen_advance). According to RfC4941 sect. 3.4 this
> should not happen.
> 
> Fix this by reparenting orphaned temporary addresses.
> 
> v2: style fixes
> 
> Signed-off-by: Heiner Kallweit <heiner.kallweit@web.de>

Looks good!

Btw. do you intend this as a bugfix for net or net-next? net-next is currently
closed and you would have to resubmit this patch as soon as net-next opens
back up. A notification will be send to this list.

Current kernels only print a warning if this happens, so IMHO net-next would
be ok?

Thanks,

  Hannes
