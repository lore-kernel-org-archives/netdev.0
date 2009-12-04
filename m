From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.32 3/3] net: Make ks8851 snl work under Beagle
 Zippy combo board
Date: Thu, 03 Dec 2009 16:05:11 -0800 (PST)
Message-ID: <20091203.160511.211490797.davem@davemloft.net>
References: <14385191E87B904DBD836449AA30269D021A42@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@simtec.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tristram.Ha@Micrel.Com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755343AbZLDAFH@vger.kernel.org>
In-Reply-To: <14385191E87B904DBD836449AA30269D021A42@MORGANITE.micrel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Date: Thu, 3 Dec 2009 13:30:03 -0800

> From: Tristram Ha <Tristram.Ha@micrel.com>
> 
> The Micrel KSZ8851 SNL Ethernet chip is used in the OMAP Beagle Zippy combo board.  Requesting interrupt using level triggering flag hangs the system because the interrupt handling routine is called continually.  Using edge triggering avoids this problem.  As a result, disabling interrupt may not be necessary.
> 
> Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>

You say "may not be necessary", do you actually know for sure?

This seems questionable, if the interrupt disabling was there
for a reason what has changed to make it such that it is no
longer necessary?
