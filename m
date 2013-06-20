From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mv643xx_eth: Allocate receive queue initialized to zero
Date: Wed, 19 Jun 2013 22:19:28 -0700 (PDT)
Message-ID: <20130619.221928.858650471566973618.davem@davemloft.net>
References: <1371576759-21782-1-git-send-email-lkundrak@v3.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: lkundrak@v3.sk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371576759-21782-1-git-send-email-lkundrak@v3.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lubomir Rintel <lkundrak@v3.sk>
Date: Tue, 18 Jun 2013 19:32:38 +0200

> Zero pointer in rx_skb is how respective rxq_deinit() finds out out that a skb
> slot is unallocated. If rxq_refill() fails (e.g. on OOM condition), subsequent
> teardown would result in an attempt to kfree() invalid pointers.
> 
> Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>

Applied.
