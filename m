From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH 2/4] tun: TUNSETFEATURES to set gso features.
Date: Tue, 01 Jul 2008 22:02:00 -0700
Message-ID: <486B0BC8.4000601@qualcomm.com>
References: <200806260028.07883.rusty@rustcorp.com.au> <200806260029.40267.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, markmc@redhat.com,
	David Miller <davem@davemloft.net>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:63295 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753405AbYGBFBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 01:01:49 -0400
In-Reply-To: <200806260029.40267.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Rusty Russell wrote:
> ethtool is useful for setting (some) device fields, but it's
> root-only.  Finer feature control is available through a tun-specific
> ioctl.
> 
> (Includes Mark McLoughlin <markmc@redhat.com>'s fix to hold rtnl sem).
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>


Agree. And it's often way more convenient to muck with the TUN settings
directly on the fd instead of using external tool.

Acked-by: Max Krasnyansky <maxk@qualcomm.com>
