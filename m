From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.33 4/4] net: Add PCI vendor and device ids for
 Micrel KSZ8841/2 PCI devices
Date: Thu, 04 Feb 2010 20:27:54 -0800 (PST)
Message-ID: <20100204.202754.252960217.davem@davemloft.net>
References: <14385191E87B904DBD836449AA30269D021A55@MORGANITE.micrel.com>
	<20100204154004.44e3d607@nehalam>
	<14385191E87B904DBD836449AA30269D5CC333@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tristram.Ha@Micrel.Com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <14385191E87B904DBD836449AA30269D5CC333@MORGANITE.micrel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Date: Thu, 4 Feb 2010 18:55:31 -0800

> Stephen Hemminger wrote:
>> Current practice is to NOT update this file and instead keep constants
> in the individual driver.
> 
> It seems I received conflicted recommendation from Alan Cox:

Alan's understanding is several years out of date.

Stephen's is correct.

But you don't need these stupid defines at all, all you
use them for is the PCI device ID table in your driver
so just use constants.
