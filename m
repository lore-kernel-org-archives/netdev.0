From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: hook up the set-tso ethtool op
Date: Fri, 24 Oct 2008 02:33:24 +1100
Message-ID: <200810240233.24387.rusty@rustcorp.com.au>
References: <1224689546.30669.4.camel@blaa>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:56621 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752708AbYJWPdc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2008 11:33:32 -0400
In-Reply-To: <1224689546.30669.4.camel@blaa>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 23 October 2008 02:32:26 Mark McLoughlin wrote:
> Seems like an oversight that we have set-tx-csum and set-sg hooked
> up, but not set-tso.
>
> Also leads to the strange situation that if you e.g. disable tx-csum,
> then tso doesn't get disabled.

Thanks, applied.

Rusty.
