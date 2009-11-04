From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 05/25] mlx4_core: add slave resource allocation
Date: Wed, 04 Nov 2009 10:19:51 -0800
Message-ID: <ada7hu617aw.fsf@cisco.com>
References: <4AF19E1E.4000102@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:46637 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757514AbZKDSTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 13:19:48 -0500
In-Reply-To: <4AF19E1E.4000102@mellanox.co.il> (Yevgeny Petrilin's message of
	"Wed, 04 Nov 2009 17:30:38 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > +	u32 param1 = *((u32 *) &vhcr->in_param);
 > +	u32 param2 = *(((u32 *) &vhcr->in_param) + 1);

Is this endian clean?

 - R.
