From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] stmmac: parameters auto-tuning through HW cap reg
Date: Thu, 17 Nov 2011 03:14:13 -0500 (EST)
Message-ID: <20111117.031413.1597402095627141168.davem@davemloft.net>
References: <1321516682-32208-1-git-send-email-peppe.cavallaro@st.com>
	<1321516682-32208-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, francesco.virlinzi@st.com,
	srinivas.kandagatla@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44305 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755661Ab1KQIOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 03:14:20 -0500
In-Reply-To: <1321516682-32208-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu, 17 Nov 2011 08:58:00 +0100

> New GMAC devices (newer than the databook 3.50a) have the
> HW capability register that provides which features are actually
> supported by the hardware.
> 
> On old devices many information have to be passed through the
> platform, for example: enhanced descriptor structure,
> TX COE etc. These are mandatory to properly configure the driver.
> This remains still valid because the driver has to support old
> Synopsys devices but now it's also able to override them using the
> values from the HW capability register if supported.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
