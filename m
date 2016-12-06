From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: clear reset value of
 snps,wr_osr_lmt/snps,rd_osr_lmt before writing
Date: Tue, 06 Dec 2016 10:34:31 -0500 (EST)
Message-ID: <20161206.103431.1801934560152684508.davem@davemloft.net>
References: <1480957974-22326-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com, niklass@axis.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: niklas.cassel@axis.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480957974-22326-1-git-send-email-niklass@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>
Date: Mon, 5 Dec 2016 18:12:54 +0100

> From: Niklas Cassel <niklas.cassel@axis.com>
> 
> WR_OSR_LMT and RD_OSR_LMT have a reset value of 1.
> Since the reset value wasn't cleared before writing, the value in the
> register would be incorrect if specifying an uneven value for
> snps,wr_osr_lmt/snps,rd_osr_lmt.
> 
> Zero is a valid value for the properties, since the databook specifies:
> maximum outstanding requests = WR_OSR_LMT + 1.
> 
> We do not want to change the behavior for existing users when the
> property is missing. Therefore, default to 1 if the property is missing,
> since that is the same as the reset value.
> 
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>

Applied, thank you.
