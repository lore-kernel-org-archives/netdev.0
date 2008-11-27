From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: large tx MTU support
Date: Thu, 27 Nov 2008 23:00:56 +1030
Message-ID: <200811272300.58151.rusty@rustcorp.com.au>
References: <1227707891.9579.44.camel@blaa>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:33514 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753160AbYK0MbF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Nov 2008 07:31:05 -0500
In-Reply-To: <1227707891.9579.44.camel@blaa>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 27 November 2008 00:28:11 Mark McLoughlin wrote:
> We don't really have a max tx packet size limit, so allow configuring
> the device with up to 64k tx MTU.

Hi Mark,

Just one comment: maybe we should be conservative and maybe limit to 1500 if 
the host doesn't offer any of the GSO or MRG_RXBUF features?

Thanks,
Rusty.
