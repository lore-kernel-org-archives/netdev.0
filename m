From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] 3com/typhoon: reuse eth_mac_addr()
Date: Wed, 22 Feb 2012 14:56:29 -0500 (EST)
Message-ID: <20120222.145629.697083360270812669.davem@davemloft.net>
References: <1329914199-30862-1-git-send-email-danny.kukawka@bisect.de>
	<1329914199-30862-2-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave@thedillows.org, dkukawka@suse.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: danny.kukawka@bisect.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329914199-30862-2-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Danny Kukawka <danny.kukawka@bisect.de>
Date: Wed, 22 Feb 2012 13:36:38 +0100

> Use eth_mac_addr() for .ndo_set_mac_address, remove
> typhoon_set_mac_address() since it do currently the same as
> eth_mac_addr(). Additional advantage: eth_mac_addr() already
> checks if the given address is valid.
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

Applied.
