From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 6/8] net/mlx4_en: allow setting number of rx rings for,
 RSS/TCP
Date: Mon, 21 Nov 2011 16:57:30 +0000
Message-ID: <1321894651.2692.1.camel@bwh-desktop>
References: <4ECA0F44.1080004@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<ogerlitz@mellanox.com>, <oren@mellanox.co.il>,
	<amirv@mellanox.co.il>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:42022 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842Ab1KUQ5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 11:57:38 -0500
In-Reply-To: <4ECA0F44.1080004@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-21 at 10:43 +0200, Yevgeny Petrilin wrote:
> From: Amir Vadai <amirv@mellanox.co.il>
> 
> Make RSS TCP divert packets only to part of the rx rings, other could be
> accessed by using flow steering or RFS acceleration
[...]

The ethtool {get,set}_rxfh_indir operations are a standard and more
flexible interface for configuring this.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
