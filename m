From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] net: m68k: Allow modular build
Date: Tue, 29 Sep 2015 21:11:33 -0700 (PDT)
Message-ID: <20150929.211133.981150232001662857.davem@davemloft.net>
References: <1443515046-13968-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, fthain@telegraphics.com.au,
	funaho@jurai.org, philb@gnu.org, netdev@vger.kernel.org,
	linux-m68k@lists.linux-m68k.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33236 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbbI3ELe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 00:11:34 -0400
In-Reply-To: <1443515046-13968-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 29 Sep 2015 10:24:01 +0200

> This patch series makes the remaining m68k Ethernet drivers modular.
> It's an alternative to the last 3 patches of Paul Gortmaker's series
> "[PATCH net-next 0/6] make non-modular code explicitly non-modular".
> 
> Note that "[PATCH 5/5] net: macmace: Allow modular build" depends on
> "[PATCH 4/5] m68k/mac: Export Peripheral System Controller (PSC) base
> address to modules". Feel free to take the dependency through the netdev
> tree to avoid modular build breakage.
> 
> This was compile-tested only (mac_defconfig + allmodconfig) due to lack
> of hardware.

Series applied, thanks Geert.
