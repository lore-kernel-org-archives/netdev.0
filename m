From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] stmmac: fix check for phydev being open
Date: Wed, 09 Sep 2015 17:08:06 -0700 (PDT)
Message-ID: <20150909.170806.1419774665265285481.davem@davemloft.net>
References: <1441810868-7212-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	peppe.cavallaro@st.com, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
To: Alexey.Brodkin@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441810868-7212-1-git-send-email-abrodkin@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Date: Wed,  9 Sep 2015 18:01:08 +0300

> Current check of phydev with IS_ERR(phydev) may make not much sense
> because of_phy_connect() returns NULL on failure instead of error value.
> 
> Still for checking result of phy_connect() IS_ERR() makes perfect sense.
> 
> So let's use combined check IS_ERR_OR_NULL() that covers both cases.
> 
> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: linux-kernel@vger.kernel.org
> Cc: stable@vger.kernel.org
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>

Applied, thanks.
