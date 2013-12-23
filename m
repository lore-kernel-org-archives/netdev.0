From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 1/2] mlx4_en: Add PTP hardware clock
Date: Mon, 23 Dec 2013 19:48:46 +0100
Message-ID: <20131223184845.GA4922@netboy>
References: <1387312359-9476-1-git-send-email-shawn.bohrer@gmail.com>
 <1387312359-9476-2-git-send-email-shawn.bohrer@gmail.com>
 <52B6E568.4030400@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shawn Bohrer <shawn.bohrer@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	tomk@rgmadvisors.com, Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f44.google.com ([209.85.214.44]:42109 "EHLO
	mail-bk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067Ab3LWStA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 13:49:00 -0500
Received: by mail-bk0-f44.google.com with SMTP id d7so2097657bkh.17
        for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 10:48:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <52B6E568.4030400@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 22, 2013 at 03:13:12PM +0200, Hadar Hen Zion wrote:

> 2. Adding spin lock in the data path reduce performance by 15% when
> HW timestamping is enabled. I did some testing and replacing
> spin_lock_irqsave with read/write_lock_irqsave prevents the
> performance decrease.

Why do the spin locks cause such a bottleneck?

Is there really that much lock contention in your test?

Your figure of 15% seems awfully high. How did you arrive at that
figure?

Thanks,
Richard
