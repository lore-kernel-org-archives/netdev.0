From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net 4/4] ip_tunnel: Remove double unregister of the
 fallback device
Date: Tue, 1 Oct 2013 12:40:46 +0200
Message-ID: <20131001104046.GK7660@secunet.com>
References: <20131001093359.GG7660@secunet.com>
 <20131001093737.GJ7660@secunet.com>
 <524A9D4C.9030900@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Pravin Shelar <pshelar@nicira.com>, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36068 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753561Ab3JAKkt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 06:40:49 -0400
Content-Disposition: inline
In-Reply-To: <524A9D4C.9030900@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 01, 2013 at 12:00:44PM +0200, Nicolas Dichtel wrote:
> 
> Note that there is the same problem in
> net/ipv6/ip6_tunnel.c:ip6_tnl_destroy_tunnels() introduced by
> 0bd8762824e7
> ("ip6tnl: add x-netns support").
> 
> Should I send a patch for it or would you take care of it?

I don't mind either way. But you noticed the problem, so
feel free to send a patch yourself.
