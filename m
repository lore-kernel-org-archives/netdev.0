From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] IPv6: enable bind() to assign an anycast address
Date: Fri, 10 Jan 2014 21:51:00 +0100
Message-ID: <20140110205100.GB23647@order.stressinduktion.org>
References: <1389377544-3119-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55170 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbaAJUvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 15:51:02 -0500
Content-Disposition: inline
In-Reply-To: <1389377544-3119-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Fri, Jan 10, 2014 at 07:12:24PM +0100, Francois-Xavier Le Bail wrote:
> - Add ipv6_chk_acast_addr_src() to check if an anycast address is link-local
>   on given interface or is global (on any interface).
> - Use it in inet6_bind().
> 
> Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
> ---
> Tested with link-local and global anycast addresses.
> Tested with SOCK_DGRAM socket, bind and UDP traffic OK.

> Tested with SOCK_STREAM socket, bind OK, traffic need another change.

What do you mean with that?

Bye,

  Hannes
