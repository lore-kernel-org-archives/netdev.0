From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: ip6_append_data_mtu did not care about pmtudisc and frag_size
Date: Mon, 1 Jul 2013 20:23:11 +0200
Message-ID: <20130701182311.GD8937@order.stressinduktion.org>
References: <20130701181742.GB8937@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, gaofeng@cn.fujitsu.com,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:48276 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754853Ab3GASXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 14:23:12 -0400
Content-Disposition: inline
In-Reply-To: <20130701181742.GB8937@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 01, 2013 at 08:17:42PM +0200, Hannes Frederic Sowa wrote:
> If the socket had an IPV6_MTU value set, ip6_append_data_mtu lost track
> of this when appending the second frame on a corked socket. This results
> in the following splat:
> 
> [...]
> 
> While there, also check if path mtu discovery is activated for this
> socket. The logic was adapted from ip6_append_data when first writing
> on the corked socket.
> 
> This bug was introduced with commit
> 0c1833797a5a6ec23ea9261d979aa18078720b74 ("ipv6: fix incorrect ipsec
> fragment").
> 
> Cc: Gao feng <gaofeng@cn.fujitsu.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/ip6_output.c | 12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)

I would love to have additional review for this patch. I am fairly sure that
this patch is correct, but...

Thanks,

  Hannes
