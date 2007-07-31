From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 39] net/ipv4/ip_options.c: kmalloc + memset conversion
 to kzalloc
Date: Tue, 31 Jul 2007 14:07:28 -0700 (PDT)
Message-ID: <20070731.140728.118970012.davem@davemloft.net>
References: <200707311845.48807.m.kozlowski@tuxland.pl>
	<200707312016.59970.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org
To: m.kozlowski@tuxland.pl
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758735AbXGaVHp@vger.kernel.org>
In-Reply-To: <200707312016.59970.m.kozlowski@tuxland.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Date: Tue, 31 Jul 2007 20:16:59 +0200

> Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

Applied, but note that this patch changes behavior, previously
only the ip_options structure base was cleared out, but now
the whole memory region is cleared.

I think it's OK for this case, but I'm just making note of it.
