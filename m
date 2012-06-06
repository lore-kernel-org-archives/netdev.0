From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v9] tilegx network driver: initial support
Date: Wed, 06 Jun 2012 11:17:46 -0700 (PDT)
Message-ID: <20120606.111746.576942199242363352.davem@davemloft.net>
References: <201205251853.q4PIrE7T000723@lab-41.internal.tilera.com>
	<201206042023.q54KNEZp003834@farm-0002.internal.tilera.com>
	<1339006223.26966.36.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cmetcalf@tilera.com, bhutchings@solarflare.com, arnd@arndb.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339006223.26966.36.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Jun 2012 20:10:23 +0200

> I am pretty sure this performance problem should be solved in net/{core|
> ipv4|ipv6} instead
> 
> What TCP performance do you get with TSO/GSO and SG off ?

We have other drivers already doing this.

I tried a few years ago to make this generic, because NIU could
benefit from it as well, but I couldn't figure out a clean enough
way to abstract this.

Therefore it is absolutely reasonable to continue to let drivers
do this locally until we actually have a reasonable solution.

The gains are definitely significant for chips that lack real TSO
hardware, I absolutely do not require "proof" of this, it is clearly
evident to anyone who considers the issue.
