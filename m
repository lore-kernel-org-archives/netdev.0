From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v2] net: macb: Increase DMA TX buffer size
Date: Thu, 25 Aug 2016 16:59:06 -0700 (PDT)
Message-ID: <20160825.165906.1864272195425576421.davem@redhat.com>
References: <cccfc176-df56-4add-e6c8-e040f9da31dc@atmel.com>
        <1472077539-18033-1-git-send-email-xander.huff@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
        nathan.sullivan@ni.com, linux-kernel@vger.kernel.org
To: xander.huff@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472077539-18033-1-git-send-email-xander.huff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xander Huff <xander.huff@ni.com>
Date: Wed, 24 Aug 2016 17:25:39 -0500

> From: Nathan Sullivan <nathan.sullivan@ni.com>
> 
> In recent testing with the RT patchset, we have seen cases where the
> transmit ring can fill even with up to 200 txbds in the ring. Increase the
> size of the DMA TX ring to avoid overruns.
> 
> Signed-off-by: Xander Huff <xander.huff@ni.com>
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>

This is really a short term solution.

While a larger TX ring may help RT, it's wasteful to have a ring that
large on non-RT.  Both uses are valid.

Therefore what really needs to happen is to make this driver support
changing the RX and TX ring sizes at runtime via ethtool just like
pretty much every other driver.

THanks.
