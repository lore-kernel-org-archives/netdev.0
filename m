From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: do not erase dst address with flow label destination
Date: Tue, 10 Dec 2013 21:58:22 +0100
Message-ID: <20131210205822.GB25505@order.stressinduktion.org>
References: <1386684946-18510-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46318 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751606Ab3LJU6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 15:58:23 -0500
Content-Disposition: inline
In-Reply-To: <1386684946-18510-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 10, 2013 at 03:15:46PM +0100, Florent Fourcot wrote:
> This patch is following b579035ff766c9412e2b92abf5cab794bff102b6
> 	"ipv6: remove old conditions on flow label sharing"
> 
> Since there is no reason to restrict a label to a
> destination, we should not erase the destination value of a
> socket with the value contained in the flow label storage.
> 
> This patch allows to really have the same flow label to more
> than one destination.
> 
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>

Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
