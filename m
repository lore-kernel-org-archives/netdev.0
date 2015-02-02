From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] stmmac: DMA threshold mode or SF mode can be
 different among multiple device instance
Date: Sun, 01 Feb 2015 23:14:50 -0800 (PST)
Message-ID: <20150201.231450.1269719582441615845.davem@davemloft.net>
References: <1422596972-18559-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	adi-buildroot-devel@lists.sourceforge.net, sonic.zhang@analog.com
To: sonic.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42460 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbbBBHOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 02:14:51 -0500
In-Reply-To: <1422596972-18559-1-git-send-email-sonic.adi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.adi@gmail.com>
Date: Fri, 30 Jan 2015 13:49:32 +0800

> From: Sonic Zhang <sonic.zhang@analog.com>
> 
> - In tx_hard_error_bump_tc interrupt, tc should be bumped only when current
> device instance is in DMA threshold mode. Check per device xstats.threshold
> other than global tc.
> 
> - Set per device xstats.threshold to SF_DMA_MODE when current device
> instance is set to SF mode.
> 
> v2-changes:
> - fix ident style
> 
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>

Applied to net-next, thanks.
