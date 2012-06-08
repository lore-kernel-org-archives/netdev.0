From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) V3] stmmac: fix driver built w/ w/o both pci
 and platf modules
Date: Thu, 07 Jun 2012 22:47:00 -0700 (PDT)
Message-ID: <20120607.224700.190797412351871914.davem@davemloft.net>
References: <20120607.110130.1448306195184899614.davem@davemloft.net>
	<1339133107-29098-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wfg@linux.intel.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933363Ab2FHFrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 01:47:00 -0400
In-Reply-To: <1339133107-29098-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Fri,  8 Jun 2012 07:25:07 +0200

> The commit ba27ec66ffeb78cbf fixes the Kconfig of the
> driver when built as module allowing to select/unselect
> the PCI and Platform modules that are not anymore mutually
> exclusive. This patch fixes and guarantees that the driver
> builds on all the platforms w/ w/o PCI and when select/unselect
> the two stmmac supports. In case of there are some problems
> on both the configuration and the pci/pltf registration the
> module_init will fail.
> 
> v2: set the CONFIG_STMMAC_PLATFORM enabled by default.
> I've just noticed that this can actually help on
> some configurations that don't enable any STMMAC
> options by default (e.g. SPEAr).
> 
> v3: change printk level when do not register the driver.
> 
> Reported-by: Fengguang Wu <wfg@linux.intel.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
