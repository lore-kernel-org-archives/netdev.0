From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hyperv: Add processing of MTU reduced by the
 host
Date: Wed, 12 Nov 2014 14:46:40 -0500 (EST)
Message-ID: <20141112.144640.703336197189868183.davem@davemloft.net>
References: <1415748472-27463-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415748472-27463-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Tue, 11 Nov 2014 15:27:52 -0800

> -	if (mtu < 68 || mtu > limit)
> +	if (mtu < ETH_DATA_LEN || mtu > limit)
>  		return -EINVAL;

This is not correct.

The test is against the minimally supported MTU, which should
be 68 not ETH_DATA_LEN which is 1500.
