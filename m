From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net-next] ipv6: split duplicate address detection and
 router solicitation timer
Date: Mon, 24 Jun 2013 15:18:55 -0300
Message-ID: <20130624181854.GA22786@obelix.rh>
References: <20130623163901.GB13836@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12490 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752586Ab3FXSTr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jun 2013 14:19:47 -0400
Content-Disposition: inline
In-Reply-To: <20130623163901.GB13836@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 23, 2013 at 06:39:01PM +0200, Hannes Frederic Sowa wrote:
> This patch splits the timers for duplicate address detection and router
> solicitations apart. The router solicitations timer goes into inet6_dev
> and the dad timer stays in inet6_ifaddr.
> 
> The reason behind this patch is to reduce the number of unneeded router
> solicitations send out by the host if additional link-local addresses
> are created. Currently we send out RS for every link-local address on
> an interface.
> 
> If the RS timer fires we pick a source address with ipv6_get_lladdr. This
> change could hurt people adding additional link-local addresses and
> specifying these addresses in the radvd clients section because we
> no longer guarantee that we use every ll address as source address in
> router solicitations.
> 
> Cc: Flavio Leitner <fleitner@redhat.com>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: David Stevens <dlstevens@us.ibm.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

The patch looks good. I tried here and saw no bugs nor problems.

Reviewed-by: Flavio Leitner <fbl@redhat.com>
