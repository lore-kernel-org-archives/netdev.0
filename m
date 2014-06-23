From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tulip: Poll link status more frequently for Comet chips
Date: Sun, 22 Jun 2014 17:13:05 -0700 (PDT)
Message-ID: <20140622.171305.2202259755276449247.davem@davemloft.net>
References: <1403431272-2569-1-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux@rainbow-software.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403431272-2569-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ondrej Zary <linux@rainbow-software.org>
Date: Sun, 22 Jun 2014 12:01:12 +0200

> It now takes up to 60 seconds to detect cable (un)plug on ADMtek Comet chips.
> That's too slow and might cause people to think that it doesn't work at all.
> 
> Poll link status every 2 seconds instead of 60 for ADMtek Comet chips.
> That should be fast enough while not stressing the system too much.
> 
> Tested with ADMtek AN983B.
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

Looks good, and this is consistent with tulip_media_timer().

Applied, thanks.
