From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 1/2] mlx4_en: Add PTP hardware clock
Date: Wed, 25 Dec 2013 18:02:58 +0100
Message-ID: <20131225170258.GA5735@netboy>
References: <1387312359-9476-1-git-send-email-shawn.bohrer@gmail.com>
 <1387312359-9476-2-git-send-email-shawn.bohrer@gmail.com>
 <52B6E568.4030400@mellanox.com>
 <20131223184845.GA4922@netboy>
 <52B992EE.5030401@mellanox.com>
 <20131225115322.GB5378@netboy>
 <CAKBbMu33zXkG4+S1kP6zB+4iKMNNoy=XVBtoqZZEkqurRsgvQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Ketterhagen <tomk@rgmadvisors.com>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f48.google.com ([209.85.214.48]:56920 "EHLO
	mail-bk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624Ab3LYRDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Dec 2013 12:03:11 -0500
Received: by mail-bk0-f48.google.com with SMTP id r7so2635736bkg.35
        for <netdev@vger.kernel.org>; Wed, 25 Dec 2013 09:03:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAKBbMu33zXkG4+S1kP6zB+4iKMNNoy=XVBtoqZZEkqurRsgvQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 25, 2013 at 08:11:00AM -0600, Shawn Bohrer wrote:
> 
> The read/write lock appears to meet these needs but also appears to be
> frowned upon and RCU seems to be preferred.  I'm a bit ignorant when it
> comes to RCU, but can it be used in this case?

No, don't use RCU. It would not make sense here. Just use
reader/writer locks.

Thanks,
Richard
