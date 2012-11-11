From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: using per-socket ipsec policies as user
Date: Sun, 11 Nov 2012 07:38:28 +0100
Message-ID: <20121111063828.GC28043@order.stressinduktion.org>
References: <20121111062155.GB28043@order.stressinduktion.org> <20121111.012551.425806345331543715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46621 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715Ab2KKGia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2012 01:38:30 -0500
Content-Disposition: inline
In-Reply-To: <20121111.012551.425806345331543715.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 11, 2012 at 01:25:51AM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Sun, 11 Nov 2012 07:21:55 +0100
> 
> > in commit 6fc0b4a xfrm policy loading via setsockopt was restricted
> > to CAP_NET_ADMIN. I wondered if the situation of the xfrm interface
> > got better since then or what needs to be done to remove this
> > restriction.
> 
> It's an intentional restrction and has a lot less to do with any
> aspect of our implementation, but rather has more to do with what
> operations we wish to allows non-privileged users to do or not.

The commit message indicated otherwise. But I am fine with that.

Thanks,

  Hannes
