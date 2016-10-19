From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git)] stmmac: fix and review the ptp registration.
Date: Wed, 19 Oct 2016 15:10:47 -0400 (EDT)
Message-ID: <20161019.151047.464176535089164279.davem@davemloft.net>
References: <1476860801-28242-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        alexandre.torgue@st.com, rayagond@vayavyalabs.com,
        dan.carpenter@oracle.com, nico@linaro.org
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476860801-28242-1-git-send-email-peppe.cavallaro@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Wed, 19 Oct 2016 09:06:41 +0200

> The commit commit 7086605a6ab5 ("stmmac: fix error check when init ptp")
> breaks the procedure added by the
> commit efee95f42b5d ("ptp_clock: future-proofing drivers against PTP
> subsystem becoming optional")
> 
> So this patch tries to re-import the logic added by the latest
> commit above: it makes sense to have the stmmac_ptp_register
> as void function and, inside the main, the stmmac_init_ptp can fails
> in case of the capability cannot be supported by the HW.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
