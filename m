From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) V2] stmmac: fix driver built w/ w/o both pci
 and platf modules
Date: Thu, 07 Jun 2012 11:01:30 -0700 (PDT)
Message-ID: <20120607.110130.1448306195184899614.davem@davemloft.net>
References: <1339062803-24273-1-git-send-email-peppe.cavallaro@st.com>
	<1339073322-23093-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wfg@linux.intel.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44743 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932605Ab2FGSBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 14:01:31 -0400
In-Reply-To: <1339073322-23093-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu,  7 Jun 2012 14:48:42 +0200

> +	pr_err("stmmac: do not register the PCI driver\n");

This is inappropriate, since this is called unconditionally.
