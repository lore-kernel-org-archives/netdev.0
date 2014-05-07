From: Wilfried Klaebe <w-lkml@lebenslange-mailadresse.de>
Subject: Re: [PATCH 23/24] net, diet: Add coccinelle script to convert
 drivers to ETHTOOL_OPS
Date: Wed, 7 May 2014 00:18:30 +0000
Message-ID: <20140507001830.GA7875@kaos.lebenslange-mailadresse.de>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
 <1399328773-6531-24-git-send-email-andi@firstfloor.org>
 <CAAxaTiOYTEQgibnpDBXdhNpJUAVrLFwxz0roq8Bin1rNnnsxgg@mail.gmail.com>
 <20140506.110504.2135392385828482331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nicolas.palix@imag.fr, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	ak@linux.intel.com, Julia.Lawall@lip6.fr, Gilles.Muller@lip6.fr
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140506.110504.2135392385828482331.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Tue, May 06, 2014 at 11:05:04AM -0400 schrieb David Miller:
> SET_ETHTOOL_OPS only exists so that drivers could be compiled
> on "older" kernels.
> 
> But the usefulness of that is long gone, we've had netdev->ethtool_ops
> since way before we started using GIT.
> 
> I'd rather see a patch which removes it, to be honest.

Something like this?

https://www.lebenslange-mailadresse.de/lkml/remove-SET_ETHTOOL_OPS.patch
