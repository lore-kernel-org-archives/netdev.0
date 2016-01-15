From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: clear interrupts when disabling them
Date: Fri, 15 Jan 2016 14:47:49 -0500 (EST)
Message-ID: <20160115.144749.588820079930764465.davem@davemloft.net>
References: <1452799647-1426-1-git-send-email-nathan.sullivan@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nathan.sullivan@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452799647-1426-1-git-send-email-nathan.sullivan@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nathan Sullivan <nathan.sullivan@ni.com>
Date: Thu, 14 Jan 2016 13:27:27 -0600

> Disabling interrupts with the IDR register does not stop the macb hardware
> from asserting its interrupt line if there are interrupts pending.  Always
> clear the interrupts using ISR, and be sure to write it on hardware that
> is not read-to-clear, like Zynq.  Not doing so will cause interrupts when
> the driver doesn't expect them.
> 
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>

Applied, thanks.
