From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] drivers/net/tulip/de4x5.c: fix union member name in
 DE4X5_GET_REG ioctl
Date: Thu, 16 Sep 2010 22:34:41 -0700 (PDT)
Message-ID: <20100916.223441.93463391.davem@davemloft.net>
References: <1284699944.2565.4.camel@dan>
	<20100916.222740.135972127.davem@davemloft.net>
	<1284701436.2565.6.camel@dan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kyle@mcmartin.ca, jeffm@suse.com,
	security@kernel.org
To: drosenberg@vsecurity.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1284701436.2565.6.camel@dan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Rosenberg <drosenberg@vsecurity.com>
Date: Fri, 17 Sep 2010 01:30:36 -0400

> Tiring doesn't begin to describe it.  Formatting undamaged.

:-)  Thanks.

> This was previously reported as a security issue due to leakage of
> uninitialized stack memory.  Jeff Mahoney pointed out that this is
> incorrect since the copied data is from a union (rather than a struct).
> Therefore, this patch is only under consideration for the sake of
> correctness, and is not security relevant. 
> 
> Signed-off-by: Dan Rosenberg <dan.j.rosenberg@gmail.com>
> Acked-by: Grant Grundler <grundler@parisc-linux.org>

Applied.
