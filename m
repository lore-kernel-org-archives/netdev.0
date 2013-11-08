From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 2/3] ipv6: increase maximum lifetime of flow labels
Date: Fri, 8 Nov 2013 13:34:38 +0100
Message-ID: <20131108123438.GC5876@order.stressinduktion.org>
References: <1383843194-22945-1-git-send-email-florent.fourcot@enst-bretagne.fr> <1383843194-22945-2-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58001 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221Ab3KHMej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 07:34:39 -0500
Content-Disposition: inline
In-Reply-To: <1383843194-22945-2-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 05:53:13PM +0100, Florent Fourcot wrote:
> If the last RFC 6437 does not give any constraints
> for lifetime of flow labels, the previous RFC 3697
> spoke of a minimum of 120 seconds between
> reattribution of a flow label.
> 
> The maximum linger is currently set to 60 seconds
> and does not allow this configuration without
> CAP_NET_ADMIN right.
> 
> This patch increase the maximum linger to 150
> seconds, allowing more flexibility to standard
> users.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
