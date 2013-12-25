From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 1/2] mlx4_en: Add PTP hardware clock
Date: Wed, 25 Dec 2013 12:49:36 +0100
Message-ID: <20131225114934.GA5378@netboy>
References: <1387312359-9476-1-git-send-email-shawn.bohrer@gmail.com>
 <1387312359-9476-2-git-send-email-shawn.bohrer@gmail.com>
 <52B6E568.4030400@mellanox.com>
 <20131223162957.GA6810@lintop.rgmadvisors.com>
 <20131223165934.GB6810@lintop.rgmadvisors.com>
 <52B9AA7B.8090401@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shawn Bohrer <shawn.bohrer@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	tomk@rgmadvisors.com, Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:52835 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab3LYLtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Dec 2013 06:49:49 -0500
Received: by mail-bk0-f54.google.com with SMTP id v16so2587040bkz.13
        for <netdev@vger.kernel.org>; Wed, 25 Dec 2013 03:49:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <52B9AA7B.8090401@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 24, 2013 at 05:38:35PM +0200, Hadar Hen Zion wrote:
> 
> The spin lock is needed when reading hardware registers.

Or when using a structure of fields that act together as one object.

> My suggestion is to stay with spin locks in all the places
> protecting timecounter_read()/timecounter_init() and just remove the
> spin lock from timecounter_cyc2time()

If you look at the implementation of timecounter_cyc2time, you will
see that locks are, in fact, needed.

See also the comments in clocksource.h.

Thanks,
Richard
