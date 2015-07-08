From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v1 02/12] IB/core: Find the network device matching
 connection parameters
Date: Wed, 8 Jul 2015 14:33:25 -0600
Message-ID: <20150708203325.GB16812@obsidianresearch.com>
References: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
 <1434976961-27424-3-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:60313 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933000AbbGHUd1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2015 16:33:27 -0400
Content-Disposition: inline
In-Reply-To: <1434976961-27424-3-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 22, 2015 at 03:42:31PM +0300, Haggai Eran wrote:
> +/**
> + * ib_get_net_dev_by_params() - Return the appropriate net_dev
> + * for a received CM request
> + * @dev:	An RDMA device on which the request has been received.
> + * @port:	Port number on the RDMA device.
> + * @pkey:	The Pkey the request came on.
> + * @gid:	A GID that the net_dev uses to communicate.
> + * @addr:	Contains the IP address that the request specified as its
> + *		destination.
> + */
> +struct net_device *ib_get_net_dev_by_params(struct ib_device *dev, u8 port,
> +					    u16 pkey, const union ib_gid *gid,
> +					    const struct sockaddr *addr);

I feel like this has been repated a few times now, but kdocs should be
with the function body, not in the header.

Reviewed-By: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>

Jason
