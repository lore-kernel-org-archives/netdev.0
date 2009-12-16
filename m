From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with vhost-net
Date: Wed, 16 Dec 2009 13:11:40 +1030
Message-ID: <200912161311.40644.rusty@rustcorp.com.au>
References: <20091213122512.GA17255@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>, mst@redhat.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:54571 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751370AbZLPClp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2009 21:41:45 -0500
In-Reply-To: <20091213122512.GA17255@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 13 Dec 2009 10:55:12 pm Herbert Xu wrote:
> Please see what a real Ethernet driver (e.g., tg3 or ixgbe) does
> for queue management.

Hi Herbert,

   Thanks for the hint.  They seem to use NAPI for xmit cleanup, so that's
what we should do?  I'll try, but such a rewrite doesn't belong in 2.6.32.

Sridhar, if you simply remove the dev_warn() does that restore some
performance?  I'll work on a proper fix for 2.6.33 now.

Thanks,
Rusty.
