From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 1/3] net: ipv6: minor: use in6addr_any in token init
Date: Tue, 9 Apr 2013 22:37:40 +0200
Message-ID: <20130409203740.GB14572@order.stressinduktion.org>
References: <1365515236-7154-1-git-send-email-dborkman@redhat.com> <1365515236-7154-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33414 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935899Ab3DIUhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 16:37:41 -0400
Content-Disposition: inline
In-Reply-To: <1365515236-7154-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 09, 2013 at 03:47:14PM +0200, Daniel Borkmann wrote:
> Since we check for !ipv6_addr_any(&in6_dev->token) in
> addrconf_prefix_rcv(), make the token initialization on
> device setup more intuitive by using in6addr_any as an
> initializer.
> 
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
