From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 4/4] stmmac: do not fail when probe and there is no
 csr clk defined
Date: Thu, 19 Apr 2012 20:09:26 -0400 (EDT)
Message-ID: <20120419.200926.673327674879645854.davem@davemloft.net>
References: <1334814502-29707-1-git-send-email-peppe.cavallaro@st.com>
	<1334814502-29707-4-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55381 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919Ab2DTAJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 20:09:31 -0400
In-Reply-To: <1334814502-29707-4-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu, 19 Apr 2012 07:48:22 +0200

> On some platforms, for example where we are doing the bring-up,
> the csr clock is not passed from the framework and the Ethernet
> device driver is failing when it can work w/o any issues and
> using the default values. So this patch just warnings the case
> of the csr clock cannot be acquired but w/o failing the probe
> step. I have just tested it on ST STiH415 SoC (ARM).
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
