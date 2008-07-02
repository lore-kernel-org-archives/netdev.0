From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH 1/4] tun: Interface to query tun/tap features.
Date: Tue, 01 Jul 2008 21:59:02 -0700
Message-ID: <486B0B16.10205@qualcomm.com>
References: <200806260028.07883.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:58463 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762584AbYGBE6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 00:58:51 -0400
In-Reply-To: <200806260028.07883.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Rusty Russell wrote:
> The problem with introducing checksum offload and gso to tun is they
> need to set dev->features to enable GSO and/or checksumming, which is
> supposed to be done before register_netdevice(), ie. as part of
> TUNSETIFF.
> 
> Unfortunately, TUNSETIFF has always just ignored flags it doesn't
> understand, so there's no good way of detecting whether the kernel
> supports new IFF_ flags.
> 
> This patch implements a TUNGETFEATURES ioctl which returns all the valid IFF
> flags.  It could be extended later to include other features.

<snip>

Looks good.

Dave, do you want me to put all outstanding TUN patches into a git tree so
that you can pull them in one shot ?
Otherwise if you're ok with applying them one by one please apply this one.

Acked-by: Max Krasnyansky <maxk@qualcomm.com>
