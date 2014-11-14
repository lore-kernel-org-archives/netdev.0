From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inetdevice: fixed signed integer overflow
Date: Fri, 14 Nov 2014 17:09:41 -0500 (EST)
Message-ID: <20141114.170941.444338853371717833.davem@davemloft.net>
References: <1e488fa546724140b55c8d4bd6b5a9d6@S1688.EX1688.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, ja@ssi.bg, nicolas.dichtel@6wind.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: vincent.benayoun@trust-in-soft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1e488fa546724140b55c8d4bd6b5a9d6@S1688.EX1688.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vincent Benayoun <vincent.benayoun@trust-in-soft.com>
Date: Thu, 13 Nov 2014 15:04:57 +0000

> From f25ff0f2645f9763552147d480f86973b7041e26 Mon Sep 17 00:00:00 2001
> From: Vincent BENAYOUN <vincent.benayoun@trust-in-soft.com>
> Date: Thu, 13 Nov 2014 13:47:26 +0100
> Subject: [PATCH] inetdevice: fixed signed integer overflow
> 
> There could be a signed overflow in the following code.
> 
> The expression, (32-logmask) is comprised between 0 and 31 included.
> It may be equal to 31.
> In such a case the left shift will produce a signed integer overflow.
> According to the C99 Standard, this is an undefined behavior.
> A simple fix is to replace the signed int 1 with the unsigned int 1U.
> 
> Signed-off-by: Vincent BENAYOUN <vincent.benayoun@trust-in-soft.com>

Applied, thanks.
