From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 14/23 v3] mlx4_core: Determine primary physical function
Date: Thu, 04 Feb 2010 14:30:41 -0800
Message-ID: <ada3a1gfxbi.fsf@roland-alpha.cisco.com>
References: <49BFC313.1030901@mellanox.co.il>
	<4B6AEE1F.5050506@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:43904 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758373Ab0BDWau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 17:30:50 -0500
In-Reply-To: <4B6AEE1F.5050506@mellanox.co.il> (Yevgeny Petrilin's message of
	"Thu, 04 Feb 2010 17:56:15 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > +	MLX4_FLAG_PF		= 1 << 5,

Am I mistaken, or is this the only place this flag appears anywhere in
the patch set?  In other words it is never set and never tested -- so
probably we don't need it?

 > +	dev_cap->pf_num = field;
 > +	if (dev_cap->pf_num > 1)
 > +		dev->flags |= MLX4_FLAG_MASTER;

Is this correct?  All PFs > 1 are masters?  Or should the test be "== 1"
rather than "> 1" instead?
-- 
Roland Dreier <rolandd@cisco.com>
Cisco.com - http://www.cisco.com

For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
