From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: stmmac: replace all pr_xxx by their
 netdev_xxx counterpart
Date: Thu, 17 Nov 2016 13:30:58 -0500 (EST)
Message-ID: <20161117.133058.1156121923515618186.davem@davemloft.net>
References: <1479323381-26639-1-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479323381-26639-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Wed, 16 Nov 2016 20:09:39 +0100

> From: LABBE Corentin <clabbe.montjoie@gmail.com>
> 
> The stmmac driver use lots of pr_xxx functions to print information.
> This is bad since we cannot know which device logs the information.
> (moreover if two stmmac device are present)
> 
> Furthermore, it seems that it assumes wrongly that all logs will always
> be subsequent by using a dev_xxx then some indented pr_xxx like this:
> kernel: sun7i-dwmac 1c50000.ethernet: no reset control found
> kernel:  Ring mode enabled
> kernel:  No HW DMA feature register supported
> kernel:  Normal descriptors
> kernel:  TX Checksum insertion supported
> 
> So this patch replace all pr_xxx by their netdev_xxx counterpart.
> Excepts for some printing where netdev "cause" unpretty output like:
> sun7i-dwmac 1c50000.ethernet (unnamed net_device) (uninitialized): no reset control found
> In those case, I keep dev_xxx.
> 
> In the same time I remove some "stmmac:" print since
> this will be a duplicate with that dev_xxx displays.
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Applied to net-next.
