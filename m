From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git)] stmmac: fix PWRDWN into the PMT register for
 global unicast.
Date: Sun, 18 Sep 2016 22:21:32 -0400 (EDT)
Message-ID: <20160918.222132.2281635475128921557.davem@davemloft.net>
References: <1474015813-5400-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexandre.torgue@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51856 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936428AbcISCVf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 22:21:35 -0400
In-Reply-To: <1474015813-5400-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Fri, 16 Sep 2016 10:50:13 +0200

> MAC devices use the RWKPKTEN and MGKPKTEN bits of the PMT Control/Status
> register to generate power management events.
> So this patch is to properly set the RWKPKTEN [BIT(2)] inside the
> PMT register (needed in case of global unicast).
> 
> Reported-by: Aditi SHARMA <aditi-hed.sharma@st.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
