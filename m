From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git)] stmmac: fix resource management when resume
Date: Sat, 05 Dec 2015 17:49:34 -0500 (EST)
Message-ID: <20151205.174934.1926276723353475569.davem@davemloft.net>
References: <1449210066-30336-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39371 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbbLEWtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 17:49:35 -0500
In-Reply-To: <1449210066-30336-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Fri, 4 Dec 2015 07:21:06 +0100

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

Applied, thanks.
