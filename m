From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [ipsec PATCH 0/3] Preserve skb->mark through VTI tunnels
Date: Thu, 28 May 2015 07:58:48 +0200
Message-ID: <20150528055845.GH27342@secunet.com>
References: <20150527141042.1576.47399.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-crypto@vger.kernel.org>,
	<davem@davemloft.net>, <herbert@gondor.apana.org.au>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49228 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750906AbbE1F6x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 01:58:53 -0400
Content-Disposition: inline
In-Reply-To: <20150527141042.1576.47399.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 27, 2015 at 07:16:37AM -0700, Alexander Duyck wrote:
> These patches are meant to try and address the fact the VTI tunnels are
> currently overwriting the skb->mark value.  I am generally happy with the
> first two patches, however the third patch still modifies the skb->mark,
> though it undoes after the fact.
> 
> The main problem I am trying to address is the fact that currently if I use
> an v6 over v6 VTI tunnel I cannot receive any traffic on the interface as
> the skb->mark is bleeding through and causing the traffic to be dropped.
> 
> ---
> 
> Alexander Duyck (3):
>       ip_vti/ip6_vti: Do not touch skb->mark on xmit
>       xfrm: Override skb->mark with tunnel->parm.i_key in xfrm_input
>       ip_vti/ip6_vti: Preserve skb->mark after rcv_cb call

All applied to the ipsec tree, thanks a lot Alexander!
