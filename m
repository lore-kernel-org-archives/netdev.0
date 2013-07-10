From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: [GIT] Networking
Date: Wed, 10 Jul 2013 14:25:23 +0200
Message-ID: <20130710122523.GA357@x4>
References: <20130709.145325.1363244885668360965.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Brodkin <Alexey.Brodkin@synopsys.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130709.145325.1363244885668360965.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013.07.09 at 14:53 -0700, David Miller wrote:
> 
> Alexey Brodkin (2):
>       ethernet/arc/arc_emac - Add new driver
>       arc_emac: fix compile-time errors & warnings on PPC64

This driver defaults to y for no reason:

+config NET_VENDOR_ARC
+       bool "ARC devices"
+       default y

-- 
Markus
