From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net-next 1/2] ipv6: introduce per-interface counter for
 dad-completed ipv6 addresses
Date: Thu, 27 Jun 2013 19:02:36 -0300
Message-ID: <20130627220236.GA25037@obelix.rh>
References: <20130626220656.GA20845@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25385 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754291Ab3F0WCl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jun 2013 18:02:41 -0400
Content-Disposition: inline
In-Reply-To: <20130626220656.GA20845@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 27, 2013 at 12:06:56AM +0200, Hannes Frederic Sowa wrote:
> To reduce the number of unnecessary router solicitations, MLDv2 and IGMPv3
> messages we need to track the number of valid (as in non-optimistic,
> no-dad-failed and non-tentative) link-local addresses. Therefore, this
> patch implements a valid_ll_addr_cnt in struct inet6_dev.
> 
> We now only emit router solicitations if the first link-local address
> finishes duplicate address detection.
> 
> The changes for MLDv2 and IGMPv3 are in a follow-up patch.
> 
> While there, also simplify one if statement(one minor nit I made in one
> of my previous patches):
> 
> if (!...)
> 	do();
> else
> 	return;
> 
> <<into>>
> 
> if (...)
> 	return;
> do();
> 
> Cc: Flavio Leitner <fbl@redhat.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Cc: David Stevens <dlstevens@us.ibm.com>
> Suggested-by: David Stevens <dlstevens@us.ibm.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

Looks good and works here.
thanks,
Acked-by: Flavio Leitner <fbl@redhat.com>
