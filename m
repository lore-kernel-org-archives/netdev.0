From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 3/5] virtio_net: Add a set_rx_mode interface
Date: Mon, 19 Jan 2009 09:32:54 +0000
Message-ID: <1232357574.5627.18.camel@blaa>
References: <20090116211312.22836.34331.stgit@debian.lart>
	 <20090116211328.22836.70727.stgit@debian.lart>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au, kvm@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39517 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754397AbZASJdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2009 04:33:00 -0500
In-Reply-To: <20090116211328.22836.70727.stgit@debian.lart>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-01-16 at 14:13 -0700, Alex Williamson wrote:
> Make use of the RX_MODE control virtqueue class to enable the
> set_rx_mode netdev interface.  This allows us to selectively
> enable/disable promiscuous and allmulti mode so we don't see
> packets we don't want.  We'll automatically enable these as
> needed if additional unicast or multicast addresses are
> requested.
> 
> Signed-off-by: Alex Williamson <alex.williamson@hp.com>

Acked-by: Mark McLoughlin <markmc@redhat.com>

Cheers,
Mark.

