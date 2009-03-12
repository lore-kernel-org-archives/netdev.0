From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Fri, 13 Mar 2009 08:09:49 +1030
Message-ID: <200903130809.49523.rusty@rustcorp.com.au>
References: <200903121946.24847.rusty@rustcorp.com.au> <1295ed070903120547q431b5b40n71b8d2e98719e18d@mail.gmail.com> <20090312.055235.56926675.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: pktoss@gmail.com, dcbw@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:44413 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753103AbZCLVj4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2009 17:39:56 -0400
In-Reply-To: <20090312.055235.56926675.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 12 March 2009 23:22:35 David Miller wrote:
> Not adding a link state handler to virtio_net for pompous reasons like
> some theoretical "clean design" claim is idiotic, and in the end bad
> for users who are using existing versions of NetworkManager.

We really don't know if there's a carrier: virtio_net doesn't support it
(yet).

Dan said we can't return "don't know", but he's wrong: you get
-EOPNOTSUPP from ETHTOOL_GLINK.  That surely gives userspace the best
possible information.

> If the link is always on, you should make that explicit by providing
> a link state handler, and making sure it always returns true.

"If".  We've discussed adding a virtio_net feature to indicate link status,
which implies that it's *not* always on.

Rusty.
