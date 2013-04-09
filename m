From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 3/3] net: ipv6: only invalidate previously tokenized addresses
Date: Tue, 9 Apr 2013 22:38:12 +0200
Message-ID: <20130409203812.GD14572@order.stressinduktion.org>
References: <1365515236-7154-1-git-send-email-dborkman@redhat.com> <1365515236-7154-4-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33423 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935899Ab3DIUiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 16:38:13 -0400
Content-Disposition: inline
In-Reply-To: <1365515236-7154-4-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 09, 2013 at 03:47:16PM +0200, Daniel Borkmann wrote:
> Instead of invalidating all IPv6 addresses with global scope
> when one decides to use IPv6 tokens, we should only invalidate
> previous tokens and leave the rest intact until they expire
> eventually (or are intact forever). For doing this less greedy
> approach, we're adding a bool at the end of inet6_ifaddr structure
> instead, for two reasons: i) per-inet6_ifaddr flag space is
> already used up, making it wider might not be a good idea,
> since ii) also we do not necessarily need to export this
> information into user space.
> 
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
