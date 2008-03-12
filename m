From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] Remove NPROTO.
Date: Wed, 12 Mar 2008 18:34:26 +1100
Message-ID: <200803121834.26493.rusty@rustcorp.com.au>
References: <200803121224.25228.rusty@rustcorp.com.au> <20080311.211441.105701252.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:57329 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750875AbYCLHfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2008 03:35:09 -0400
In-Reply-To: <20080311.211441.105701252.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 12 March 2008 15:14:41 David Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Wed, 12 Mar 2008 12:24:25 +1100
>
> > NPROTO seems redundant; it's equal to AF_MAX/PF_MAX.
> >
> > It's fairly simple to find all users and replace them appropriately.
> >
> > Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
>
> Redundant, but exported to userspace for about 15 years.
>
> We'd be wise to not remove it.

Thanks.  Should we #define NPROTO AF_MAX then?

Rusty.
