From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] do not disable sg when packet requires no checksum
Date: Thu, 20 Sep 2012 22:32:37 -0400 (EDT)
Message-ID: <20120920.223237.770883586764737313.davem@davemloft.net>
References: <cover.1348105262.git.ecashin@coraid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, bhutchings@solarflare.com,
	jesse@nicira.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ecashin@coraid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1348105262.git.ecashin@coraid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ed Cashin <ecashin@coraid.com>
Date: Wed, 19 Sep 2012 18:46:07 -0700

> This two-part patchset replaces an earlier net-only patch that
> added an explicit check for the AoE protocol to harmonize_features
> in net/core/dev.c.
> 
> Following the suggestions of Ben Hutchings, this patchset makes
> the decision in the network layer protocol agnostic instead of
> using ETH_P_AOE as a special case.  It relies on fresh skbs being
> CHECKSUM_NONE but makes that explicit with an assertion.
> 
> Ed L. Cashin (2):
>   aoe: assert AoE packets marked as requiring no checksum
>   net: do not disable sg for packets requiring no checksum

Applied and queued up for -stable, thanks Ed.
