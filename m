From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/3] skb_partial_csum_set
Date: Wed, 16 Jan 2008 08:03:05 +1100
Message-ID: <200801160803.06052.rusty@rustcorp.com.au>
References: <200801152141.56172.rusty@rustcorp.com.au> <20080115.031422.06112893.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38499 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754904AbYAOVDn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 16:03:43 -0500
In-Reply-To: <20080115.031422.06112893.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 15 January 2008 22:14:22 David Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Tue, 15 Jan 2008 21:41:55 +1100
>
> > Implement skb_partial_csum_set, for setting partial csums on untrusted
> > packets.
> >
> > Use it in virtio_net (replacing buggy version there), it's also going
> > to be used by TAP for partial csum support.
> >
> > Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
>
> Looks fine to me.
>
> Acked-by: David S. Miller <davem@davemloft.net>
>
> If you like I can merge this into my net-2.6.25 tree, or alternatively
> if it makes your life easier you then you can handle it yourself.

Thanks, that will reduce coordination pain.

Cheers,
Rusty.
