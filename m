From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 00/13] net: ethernet: ti: cpsw: split driver data
 and per ndev data
Date: Wed, 10 Aug 2016 17:28:05 -0700 (PDT)
Message-ID: <20160810.172805.1742489787835736863.davem@davemloft.net>
References: <1470784964-26440-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com, linux-omap@vger.kernel.org,
	linux-kernel@vger.kernel.org, dlide@ti.com
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470784964-26440-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Wed, 10 Aug 2016 02:22:31 +0300

> In dual_emac mode the driver can handle 2 network devices. Each of them can use
> its own private data and common data/resources. This patchset splits common driver
> data/resources and private per net device data.
> It leads to:
> - reduce memory usage
> - increase code readability
> - allows add a bunch of simplification
> - create prerequisites to add multi-channel support,
>   when channels are shared between net devices
 ...

Series applied to net-next, thank you.
