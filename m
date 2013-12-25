From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 1/2] mlx4_en: Add PTP hardware clock
Date: Wed, 25 Dec 2013 12:53:24 +0100
Message-ID: <20131225115322.GB5378@netboy>
References: <1387312359-9476-1-git-send-email-shawn.bohrer@gmail.com>
 <1387312359-9476-2-git-send-email-shawn.bohrer@gmail.com>
 <52B6E568.4030400@mellanox.com>
 <20131223184845.GA4922@netboy>
 <52B992EE.5030401@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shawn Bohrer <shawn.bohrer@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	tomk@rgmadvisors.com, Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:57896 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab3LYLxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Dec 2013 06:53:37 -0500
Received: by mail-bk0-f54.google.com with SMTP id v16so2587615bkz.13
        for <netdev@vger.kernel.org>; Wed, 25 Dec 2013 03:53:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <52B992EE.5030401@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 24, 2013 at 03:58:06PM +0200, Hadar Hen Zion wrote:
> 
> The spin locks case such a bottleneck since I'm using multiple
> streams in my performance test. RSS mechanism scattered the streams
> between multiple RX rings while each RX ring is bound to a different
> cup.
> The describe scenario cause lock contention between the different RX rings.
> 
> Performance drops from 37.8 Gbits/sec to 32.1 Gbits/sec when spin
> locks are added and goes back to 37.8 Gbits/sec when using
> read/write locks.

And you are time stamping every received packet?

Thanks,
Richard
