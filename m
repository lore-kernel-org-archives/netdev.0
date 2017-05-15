From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: stmmac: use correct pointer when
 printing normal descriptor ring
Date: Mon, 15 May 2017 10:02:41 -0400 (EDT)
Message-ID: <20170515.100241.503769139886204675.davem@davemloft.net>
References: <20170515085606.24217-1-niklas.cassel@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com, niklass@axis.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: niklas.cassel@axis.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170515085606.24217-1-niklas.cassel@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>
Date: Mon, 15 May 2017 10:56:06 +0200

> There are two pointers in sysfs_display_ring,
> one that increments if using normal dma descriptors,
> another if using extended dma descriptors.
> 
> When printing the normal dma descriptors, the wrong pointer is used,
> thus the printed descriptor addresses are incorrect.
> 
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>

Applied, thanks.
