From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: split to core library and probe drivers
Date: Tue, 11 Nov 2014 14:35:22 -0500 (EST)
Message-ID: <20141111.143522.487269670885392572.davem@davemloft.net>
References: <1415615939-6671-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	hock.leong.kweh@intel.com, vbridgers2013@gmail.com
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60862 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669AbaKKTf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 14:35:26 -0500
In-Reply-To: <1415615939-6671-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Mon, 10 Nov 2014 12:38:59 +0200

> Instead of registering the platform and PCI drivers in one module let's move
> necessary bits to where it belongs. During this procedure we convert the module
> registration part to use module_*_driver() macros which makes code simplier.
> 
> From now on the driver consists three parts: core library, PCI, and platform
> drivers.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Applied to net-next, thanks.
