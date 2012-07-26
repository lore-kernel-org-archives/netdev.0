From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bcma: fix regression in pmu workaround reg masks
Date: Thu, 26 Jul 2012 03:06:59 -0700 (PDT)
Message-ID: <20120726.030659.2063192496743861099.davem@davemloft.net>
References: <1343294151-5691-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, linville@tuxdriver.com,
	brcm80211-dev-list@broadcom.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	seth.forshee@canonical.com, pieterpg@broadcom.com,
	brudley@broadcom.com, arend@broadcom.com, zajec5@gmail.com
To: hauke@hauke-m.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1343294151-5691-1-git-send-email-hauke@hauke-m.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hauke Mehrtens <hauke@hauke-m.de>
Date: Thu, 26 Jul 2012 11:15:51 +0200

> This fixes a regression introduced in:
> commit b9562545ef0b13c0440ccd8d6dd4111fb77cb17a
> Author: Hauke Mehrtens <hauke@hauke-m.de>
> Date:   Sat Jun 30 01:44:41 2012 +0200
> 
>     bcma: complete workaround for BCMA43224 and BCM4313
> 
> The regression broke reading of the sprom from the chip and seamed to
> cause a change of the pci id on a BCMA43224 device so that it is
> rejected by brcmsmac. If this problem occurred, after applying this
> patch, a cold boot is needed to make the device work again.
> 
> In the original patch the workaround set the intended bits in the chip
> common core chip control registers, but the patch also unset all the
> other bits in that register, because of a wrong mask. The original
> patch was based on code from brcmsmac and there was an additional
> inversing of the mask in the code setting these regs which was missing
> here. Now the regs are set like brcmsmac did it before.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
> Tested-by: Seth Forshee <seth.forshee@canonical.com>

Acked-by: David S. Miller <davem@davemloft.net>
