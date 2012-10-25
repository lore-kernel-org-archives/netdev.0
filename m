From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4/ipconfig: add device address to a KERN_INFO
 message
Date: Thu, 25 Oct 2012 03:24:42 -0400 (EDT)
Message-ID: <20121025.032442.2136601106266101183.davem@davemloft.net>
References: <5088E6AD.2040302@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Claudio.Fontana@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5088E6AD.2040302@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Claudio Fontana <Claudio.Fontana@huawei.com>
Date: Thu, 25 Oct 2012 09:13:49 +0200

> -	pr_info("     device=%s, addr=%pI4, mask=%pI4, gw=%pI4\n",
> -		ic_dev->name, &ic_myaddr, &ic_netmask, &ic_gateway);
> +
> + pr_info(" device=%s, hwaddr=%*phC, ipaddr=%pI4, mask=%pI4,
> gw=%pI4\n",
> +		ic_dev->name, ic_dev->addr_len, ic_dev->dev_addr,
> +		&ic_myaddr, &ic_netmask, &ic_gateway);

Either you or your email client have destroyed the indentation
of these statements.
