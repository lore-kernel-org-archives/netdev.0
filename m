From: Phil Sutter <n0-1@freewrt.org>
Subject: Re: [PATCH] korina: Read buffer overflow
Date: Thu, 13 Aug 2009 00:15:02 +0200
Message-ID: <20090812221509.725F74CEAA@orbit.nwl.cc>
References: <20090808164512.02C174CEAA@orbit.nwl.cc> <20090809000640.216D44CEAA@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, florian@openwrt.org,
	Roel Kluin <roel.kluin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:33804 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750890AbZHLWPK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 18:15:10 -0400
Content-Disposition: inline
In-Reply-To: <20090809000640.216D44CEAA@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sun, Aug 09, 2009 at 02:06:25AM +0200, Phil Sutter wrote:
> The following series fixes the incorrect printk formatting we already
> discussed, implements the solution from above and makes the driver use
> netdev_ops.

Obviously, I took the chance to mess things up again. These three
patches were accidentially written on top of the linux-mips tree, right
before Ralf pulled from Linus. So they do not apply cleanly to the
netdev tree, and even worse the last one is completely useless since
it's changes have already been implemented.

I will follow up to this email with an updated series of the two
remaining, valid patches. Sorry for the inconvenience.

Greetings, Phil
