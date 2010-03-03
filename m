From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC][ PATCH 0/3] vhost-net: Add mergeable RX buffer support
	to vhost-net
Date: Wed, 3 Mar 2010 09:54:32 +0200
Message-ID: <20100303075432.GA14034@redhat.com>
References: <OF8B8E9FD7.1F227ED3-ON882576DA.008312B5-882576DB.0001D5AB@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.osdl.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54694 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752480Ab0CCH6e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 02:58:34 -0500
Content-Disposition: inline
In-Reply-To: <OF8B8E9FD7.1F227ED3-ON882576DA.008312B5-882576DB.0001D5AB@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 02, 2010 at 04:20:03PM -0800, David Stevens wrote:
> These patches add support for mergeable receive buffers to
> vhost-net, allowing it to use multiple virtio buffer heads for a single
> receive packet.
>                                         +-DLS
> 
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

Do you have performance numbers (both with and without mergeable buffers
in guest)?

-- 
MST
