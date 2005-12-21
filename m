From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC][PATCH 4/5] I/OAT DMA support and TCP acceleration
Date: Tue, 20 Dec 2005 23:35:26 -0800 (PST)
Message-ID: <20051220.233526.63337356.davem@davemloft.net>
References: <1135142263.13781.21.camel@cleech-mobl>
	<43A8F43B.6020307@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christopher.leech@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, andrew.grover@intel.com,
	john.ronciak@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932311AbVLUHf1@vger.kernel.org>
To: dada1@cosmosbay.com
In-Reply-To: <43A8F43B.6020307@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 21 Dec 2005 07:20:43 +0100

> Please consider not enlarging cb[] if not CONFIG_NET_DMA ?

I also disagree with putting this thing in the cb[] at all.

Just put the dma_cookie_t explicitly into struct sk_buff,
protected by CONFIG_NET_DMA.
