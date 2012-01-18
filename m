From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pch_gbe: Do not abort probe on bad MAC
Date: Wed, 18 Jan 2012 16:41:45 -0500 (EST)
Message-ID: <20120118.164145.973182321372504360.davem@davemloft.net>
References: <965df7d0c78e4971faf8464ec3da0bb114e9b5ee.1326743419.git.dvhart@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, arjan@linux.intel.com,
	alan@linux.intel.com, tomoya.rohm@gmail.com,
	jeffrey.t.kirsher@intel.com, paul.gortmaker@windriver.com,
	jdmason@kudzu.us, netdev@vger.kernel.org,
	broonie@opensource.wolfsonmicro.com, David.Laight@ACULAB.COM,
	joe@perches.com
To: dvhart@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <965df7d0c78e4971faf8464ec3da0bb114e9b5ee.1326743419.git.dvhart@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Darren Hart <dvhart@linux.intel.com>
Date: Mon, 16 Jan 2012 11:50:19 -0800

> If the MAC is invalid or not implemented, do not abort the probe. Issue
> a warning and prevent bringing the interface up until a MAC is set manually
> (via ifconfig $IFACE hw ether $MAC).
> 
> Tested on two platforms, one with a valid MAC, the other without a MAC. The real
> MAC is used if present, the interface fails to come up until the MAC is set on
> the other. They successfully get an IP over DHCP and pass a simple ping and
> login over ssh test.
> 
> This is meant to allow the Inforce SYS940X development board:
> http://www.inforcecomputing.com/SYS940X_ECX.html
> (and others suffering from a missing MAC) to work with the mainline kernel.
> Without this patch, the probe will fail and the interface will not be created,
> preventing the user from configuring the MAC manually.
> 
> This does not make any attempt to address a missing or invalid MAC for the
> pch_phub driver.
> 
> Signed-off-by: Darren Hart <dvhart@linux.intel.com>

Applied, thanks.
