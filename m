From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: mv643xx_eth: use managed devm_kzalloc
Date: Wed, 10 Apr 2013 23:39:33 -0400 (EDT)
Message-ID: <20130410.233933.2109788843089649198.davem@davemloft.net>
References: <1365615483-26318-1-git-send-email-sebastian.hesselbarth@gmail.com>
	<1365626527-27233-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, andrew@lunn.ch, jason@lakedaemon.net,
	florian@openwrt.org, sergei.shtylyov@cogentembedded.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365626527-27233-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Date: Wed, 10 Apr 2013 22:42:07 +0200

> This patch moves shared private data kzalloc to managed devm_kzalloc and
> cleans now unneccessary kfree and error handling.
> 
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

This doesn't apply cleanly to the net-next tree.
