From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] net: sxgbe: Added dma related function and
 non-burst mode support
Date: Mon, 12 May 2014 00:57:00 -0400 (EDT)
Message-ID: <20140512.005700.1622310019794083211.davem@davemloft.net>
References: <003a01cf6b2a$e7bf5bf0$b73e13d0$%an@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	ks.giri@samsung.com, vipul.pandya@samsung.com
To: bh74.an@samsung.com
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-Reply-To: <003a01cf6b2a$e7bf5bf0$b73e13d0$%an@samsung.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Byungho An <bh74.an@samsung.com>
Date: Fri, 09 May 2014 11:03:43 +0900

> This series added 
> - functions to update rx descriptor tail pointer 
> - non burst mode support
> - fixed dma channel feature.

This description is not sufficient.

I don't understand what non fixed burst mode means, and why
it is so critical to add support for it in 'net' which is
only for bug fixes.

I also do not understand what the "mtl and dma channel" feature is,
what was wrong with it, and what exactly patch #3 is doing to fix it.

Finally, I have no idea why the tail pointer update is necessary
and what problem it is fixing.

You have several things to address in this patch series before I
can apply it.

Furthermore, you have to make it clear what tree you intend these
changes to go into.  'net' is only for bug fixes, and 'net-next'
is for cleanups and new features.

Thank you.
