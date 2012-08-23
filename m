From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] mdio: translation of MMD EEE registers
 to/from ethtool settings
Date: Wed, 22 Aug 2012 22:59:01 -0700 (PDT)
Message-ID: <20120822.225901.1361834659362538880.davem@davemloft.net>
References: <20120820145529.19390.66175.stgit@bwallan-smackover2.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com
To: bruce.w.allan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33459 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754560Ab2HWF7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 01:59:02 -0400
In-Reply-To: <20120820145529.19390.66175.stgit@bwallan-smackover2.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>
Date: Mon, 20 Aug 2012 07:55:29 -0700

> The helper functions which translate IEEE MDIO Manageable Device (MMD)
> Energy-Efficient Ethernet (EEE) registers 3.20, 7.60 and 7.61 to and from
> the comparable ethtool supported/advertised settings will be needed by
> drivers other than those in PHYLIB (e.g. e1000e in a follow-on patch).
> 
> In the same fashion as similar translation functions in linux/mii.h, move
> these functions from the PHYLIB core to the linux/mdio.h header file so the
> code will not have to be duplicated in each driver needing MMD-to-ethtool
> (and vice-versa) translations.  The function and some variable names have
> been renamed to be more descriptive.
> 
> Not tested on the only hardware that currently calls the related functions,
> stmmac, because I don't have access to any.  Has been compile tested and
> the translations have been tested on a locally modified version of e1000e.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>

Applied.
