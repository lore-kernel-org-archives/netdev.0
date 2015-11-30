From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git)] stmmac: fix resource management when resume
Date: Mon, 30 Nov 2015 14:54:17 -0500 (EST)
Message-ID: <20151130.145417.1897547211679159596.davem@davemloft.net>
References: <1448181858-5935-1-git-send-email-zhengsq@rock-chips.com>
	<1448533924-20684-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33163 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbbK3TyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 14:54:18 -0500
In-Reply-To: <1448533924-20684-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Thu, 26 Nov 2015 11:32:04 +0100

> There is a memleak when suspend/resume this driver version.
> Currently the stmmac, during resume step, reallocates all the resources
> but they are not released when suspend.
> The patch is not to release these resources but the logic has been changed.
> In fact, it is not necessary to free and reallocate all from scratch
> because the memory data will be always preserved.
> As final solution, the patch just reinit the descriptors and the rx/tx
> pointers only when resume. Tested done on STi boxes.
> 
> Reported-by: ZhengShunQian <zhengsq@rock-chips.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

This doesn't apply to the 'net' tree.
