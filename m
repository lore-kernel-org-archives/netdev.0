From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: don't set NETIF_F_FRAGLIST
Date: Thu, 6 Nov 2008 08:53:11 +1100
Message-ID: <200811060853.11566.rusty@rustcorp.com.au>
References: <> <1225888486-977-1-git-send-email-markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:59504 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752968AbYKEVxM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 16:53:12 -0500
In-Reply-To: <1225888486-977-1-git-send-email-markmc@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 05 November 2008 23:34:46 Mark McLoughlin wrote:
> We don't handle skb_shared_info->frag_list, so we shouldn't
> be setting the NETIF_F_FRAGLIST flag.

We don't?

skb_to_sgvec() should handle it OK, is there some subtlety I'm missing?

Rusty.
