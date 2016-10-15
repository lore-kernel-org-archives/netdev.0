From: David Miller <davem@davemloft.net>
Subject: Re: [patch] stmmac: fix an error code in stmmac_ptp_register()
Date: Sat, 15 Oct 2016 17:35:43 -0400 (EDT)
Message-ID: <20161015.173543.1886751731467613909.davem@davemloft.net>
References: <20161014192417.GC21917@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20161014192417.GC21917@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 14 Oct 2016 22:26:11 +0300

> PTR_ERR(NULL) is success.  We have to preserve the error code earlier.
> 
> Fixes: 7086605a6ab5 ("stmmac: fix error check when init ptp")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Good catch, applied.
