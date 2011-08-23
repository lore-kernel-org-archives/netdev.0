From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: boot test failure (net tree)
Date: Mon, 22 Aug 2011 21:02:55 -0700 (PDT)
Message-ID: <20110822.210255.1902105215409964106.davem@davemloft.net>
References: <20110823114129.ceb18da164bf7df3c145941b@canb.auug.org.au>
	<20110822.191348.2099822249437201579.davem@davemloft.net>
	<CACqU3MW4BnucRt3gxPrKPDvWEjaVuxRF1VOPWk5hTRfneyANkg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, mikey@neuling.org,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	linuxppc-dev@lists.ozlabs.org, benh@kernel.crashing.org,
	paulus@samba.org, linux-kbuild@vger.kernel.org
To: lacombar@gmail.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <CACqU3MW4BnucRt3gxPrKPDvWEjaVuxRF1VOPWk5hTRfneyANkg@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnaud Lacombe <lacombar@gmail.com>
Date: Mon, 22 Aug 2011 23:50:02 -0400

> Are you implying we need some kind of way to migrate config ?

The issue is that the dependencies for every single ethernet driver
have changed.  Some dependencies have been dropped (f.e. NETDEV_10000
and some have been added (f.e. ETHERNET, NET_VENDOR_****)

So right now an automated (non-prompted, default to no on all new
options) run on an existing config results in all ethernet drivers
getting disabled because the new dependencies don't get enabled.

This wouldn't be so bad if it was just one or two drivers, but in
this case it's every single ethernet driver which will have and hit
this problem.
