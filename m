From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 0/3] net: mvneta: fix usage as a module, and support QSGMII properly
Date: Wed, 16 Apr 2014 11:45:52 +0200
Message-ID: <20140416094551.GA1524@1wt.eu>
References: <1397569821-5530-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Dmitri Epshtein <dima@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	George Joseph <george.joseph@fairview5.com>, arno@natisbad.org,
	Alexander Reuter <Alexander.Reuter@gmx.net>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:6659 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751105AbaDPJqw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2014 05:46:52 -0400
Content-Disposition: inline
In-Reply-To: <1397569821-5530-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

On Tue, Apr 15, 2014 at 03:50:18PM +0200, Thomas Petazzoni wrote:
(...)
> This set of patches has been tested on:
> 
>  * Armada XP GP (four QSGMII interfaces)
>  * Armada XP DB (two RGMII interfaces and two SGMII interfaces)
>  * Armada 370 Mirabox (two RGMII interfaces)
> 
> I've tested both the driver built-in, and compiled as a module.
> 
> Since the last attempt at fixing this was quite a fiasco, I'd like
> this new attempt to be tested more widely before being applied. I'll
> try to do some testing on other Armada boards I have, but independent
> testing from other persons would also be appreciated.
> 
> Note that these patches apply after reverting the previous attempt,
> obviously.

Just tried on the AX3 using 3.14 with the last fix reverted, and it
works fine here as well both built-in and as a module. Feel free to
add my :

  Tested-by: Willy Tarreau <w@1wt.eu>

Great work!
Willy
