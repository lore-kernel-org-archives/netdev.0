From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: stmmac: Use msleep rather then udelay for
 reset delay
Date: Tue, 15 Sep 2015 15:05:48 -0700 (PDT)
Message-ID: <20150915.150548.1197620792036413505.davem@davemloft.net>
References: <1442003149-10717-1-git-send-email-sjoerd.simons@collabora.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sjoerd.simons@collabora.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442003149-10717-1-git-send-email-sjoerd.simons@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sjoerd Simons <sjoerd.simons@collabora.co.uk>
Date: Fri, 11 Sep 2015 22:25:48 +0200

> The reset delays used for stmmac are in the order of 10ms to 1 second,
> which is far too long for udelay usage, so switch to using msleep.
> 
> Practically this fixes the PHY not being reliably detected in some cases
> as udelay wouldn't actually delay for long enough to let the phy
> reliably be reset.
> 
> Signed-off-by: Sjoerd Simons <sjoerd.simons@collabora.co.uk>

Applied, thanks.
