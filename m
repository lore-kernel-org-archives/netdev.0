From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] percpu: add __percpu sparse annotations
 to net drivers
Date: Tue, 16 Feb 2010 20:21:11 -0800 (PST)
Message-ID: <20100216.202111.104057398.davem@davemloft.net>
References: <4B7B445A.1080108@kernel.org>
	<4B7B4484.4060909@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	sfr@canb.auug.org.au
To: tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B7B4484.4060909@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tejun Heo <tj@kernel.org>
Date: Wed, 17 Feb 2010 10:21:08 +0900

> Add __percpu sparse annotations to net drivers.
> 
> These annotations are to make sparse consider percpu variables to be
> in a different address space and warn if accessed without going
> through percpu accessors.  This patch doesn't affect normal builds.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Acked-by: David S. Miller <davem@davemloft.net>

Applied.
